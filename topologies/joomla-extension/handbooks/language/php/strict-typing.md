# Handbook: Type Safety (Joomla PHP variant)

**Scope:** PRs touching `**/*.php` files in a Joomla extension project.
**Enforcement:** advisory.

> **Important — this is NOT a Joomla standard.** Joomla core does **not** use `declare(strict_types=1)`, and its MVC classes (Models, Views, Controllers, Tables) are largely **untyped** — no return-type declarations, untyped parameters. This holds in both Joomla 5 (`5.4-dev`) and Joomla 6 (`6.2-dev`): the core files are the same shape, with no `strict_types` and no method typing. Verified against `com_banners` and `com_contact`. `strict_types` + type hints are general modern-PHP hygiene, not a Joomla coding-standard requirement and not part of PSR-12 / PER. Treat everything below as **opt-in encouragement for new standalone code**, never as a rule that flags code written in the core idiom.

## The rule

Type hints and `strict_types` are **encouraged on new, standalone domain/service classes** where they help PHPStan catch bugs — but they are optional, and their absence is never a finding when the code follows Joomla's core MVC conventions.

| Encouraged (new standalone code) | Pattern |
|---|---|
| Strict types declaration | `declare(strict_types=1);` after the file header, when adding a brand-new non-MVC class (value objects, services, pure helpers) |
| Return / parameter types | `public function getItems(): array` where the type is stable and known |
| Property types | `private DatabaseInterface $db;` |
| PHPStan | A `phpstan.neon` at a level the project can actually pass — level 1–2 is a realistic starting point for a Joomla extension; raise it incrementally |

## Why (and why it's limited)

Without `strict_types`, PHP silently coerces `"123abc"` to `123` at an `int` boundary — a real class of runtime bug. So on *new, self-contained* logic (a price calculator, a DTO, a service object) types are worth adding.

But a Joomla extension is mostly MVC classes that extend core base classes (`ListModel`, `FormModel`, `BaseController`, `HtmlView`, `Table`). Core overrides like `populateState($ordering = 'a.name', $direction = 'asc')` or `getItem($pk = null)` are **untyped by design**, and matching the parent's loose signature is correct. Adding stricter types to an override can even break LSP compatibility with the base class. That is why this handbook does **not** require typing and does **not** flag its absence — doing so would flag idiomatic Joomla code, including core itself.

## What Rex flags

Keep this list small and non-noisy. Surface a finding ONLY when:

1. A `phpstan.neon` that already exists is **removed**, or its level is **lowered**.
2. A `@phpstan-ignore` / `@phpstan-ignore-next-line` annotation is added with **no comment** explaining why.
3. A *new, standalone non-MVC class* (not extending a Joomla base class) uses `mixed` with no docblock, or contradicts its own declared types.

Do **NOT** flag:

- Missing `declare(strict_types=1);` — core doesn't use it.
- An MVC method (overriding a core base class) without return/parameter types — that matches core and the parent signature.
- An untyped property on a class extending a Joomla base class.

## Sample finding

> **Type safety (PHP)** — `phpstan.neon` was deleted in this PR. If the project intentionally dropped static analysis, note it in the PR description; otherwise restore it. (Advisory — not a merge blocker.)
>
> **Type safety (PHP)** — `src/Service/PriceCalculator.php:30` adds `@phpstan-ignore-next-line` with no explanation. Add a one-line comment saying what PHPStan is wrong about, so the suppression is reviewable.

## What's NOT a violation

- Any file without `declare(strict_types=1);` — **this is the core norm, J5 and J6.**
- MVC classes (`*Model`, `*Controller`, `*View`, `*Table`) with untyped methods that mirror their core parent signatures.
- Generated code (install scripts, XML form definitions).
- Test files under `tests/`.
- Legacy code touched only for a one-line fix.

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
