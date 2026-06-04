# Handbook: Clean Architecture Layering (Joomla variant)

**Scope:** all PRs in a Joomla extension project.
**Enforcement:** advisory.

## The rule

A Joomla extension under ApexYard's Joomla topology follows the MVC + service-provider pattern with a strict dependency direction. The structure applies to both Administrator and Site parts of a component:

```
src/Extension/    ← Extension class (public face, registered via DI)
src/Controller/   ← Handles HTTP requests, delegates to Model
src/Model/        ← Business logic + database queries
src/View/         ← Prepares data for rendering
src/Table/        ← Active-record wrappers for individual DB tables
src/Field/        ← Custom form fields
src/Helper/       ← Stateless utility classes
tmpl/             ← PHP template files (presentation only)
forms/            ← XML form definitions
services/         ← DI service provider (wiring point)
sql/              ← Install/update/uninstall SQL scripts
```

| Layer | What lives there | CAN import | CANNOT import |
|---|---|---|---|
| `tmpl/` | Layout files rendering HTML | `$this->escape()`, `HTMLHelper`, `LayoutHelper`, display variables set by the View | Model classes, Table classes, `Factory::getContainer()` directly |
| `src/View/` | View classes extending `HtmlView` | Model (via `$this->getModel()`), `HTMLHelper` | Table classes directly, raw SQL |
| `src/Controller/` | Controller classes extending `BaseController` / `FormController` | Model (via `$this->getModel()`), `$app->redirect()` | Table, View internals, raw SQL |
| `src/Model/` | Model classes extending `BaseDatabaseModel` / `ListModel` / `FormModel` / `AdminModel` | Table (via `$this->getTable()`), `$db` query builder, domain logic | Controller, View, tmpl |
| `src/Table/` | Table classes extending `Table` | `$db`, column definitions, Joomla's `Table` API | Model internals, Controller, View |
| `services/provider.php` | DI service provider | Any — this is the wiring point | (outermost layer) |

## Why

PHP has no compile-time module boundaries. The Joomla MVC framework enforces a convention, but nothing prevents a template file from calling `Factory::getContainer()->get(DatabaseInterface::class)` and running raw SQL. When this happens, the template becomes untestable, the query escaping is often skipped, and a single template change can break the database.

The service-provider (`services/provider.php`) is the designated wiring point. All dependencies flow through it into the Extension class, and from there into MVC classes via factories.

## What Rex flags

Surface a finding when:

1. A `tmpl/*.php` file contains a `use` statement for a Model, Table, or database class, or calls `Factory::getContainer()`.
2. A Controller class directly instantiates a Model or Table (should use `$this->getModel()` / `$this->getTable()`).
3. A View class runs raw SQL queries instead of delegating to the Model.
4. A Model class imports or instantiates a Controller or View.
5. A Table class contains business logic beyond column validation (the `check()` method should stay lean).
6. `services/provider.php` is missing or doesn't register the extension under `ComponentInterface` / `BootableExtensionInterface`.

## Sample finding

> **Clean architecture (Joomla)** — `administrator/components/com_example/tmpl/items/default.php:8` imports `use Joomla\CMS\Factory` and calls `Factory::getContainer()->get(DatabaseInterface::class)` to run a raw query. Templates should only render data provided by the View. Move the query to the Model; have the View set it as a display variable.

## What's NOT a violation

- `services/provider.php` importing from any layer — it's the wiring point.
- `tmpl/` files using `HTMLHelper`, `LayoutHelper`, `Text::_()` — these are presentation utilities.
- Install scripts (`script.php`) that access the database during install/update — they run outside the MVC lifecycle.
- Test files under `tests/` cross-importing freely.

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
