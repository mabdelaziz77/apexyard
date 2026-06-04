# Handbook: Namespace & Autoloading Conventions (Joomla PHP variant)

**Scope:** PRs touching `**/*.php` files or the extension manifest XML in a Joomla extension project.
**Enforcement:** advisory.

## The rule

Every class in a Joomla extension uses PSR-4 namespaces registered through the extension's manifest `<namespace>` element. The namespace structure must match the filesystem path under `src/`.

| Extension type | Namespace pattern | Manifest declaration |
|---|---|---|
| Component | `<Vendor>\Component\<Name>\{Administrator,Site}\` | `<namespace path="src">Vendor\Component\Name</namespace>` |
| Plugin | `<Vendor>\Plugin\<Group>\<Name>\` | `<namespace path="src">Vendor\Plugin\Group\Name</namespace>` |
| Module | `<Vendor>\Module\<Name>\{Site,Administrator}\` | `<namespace path="src">Vendor\Module\Name</namespace>` |

| Required | Pattern |
|---|---|
| Namespace-to-path mapping | `Vendor\Component\Example\Administrator\Model\ItemModel` → `administrator/components/com_example/src/Model/ItemModel.php` |
| One class per file | File name matches class name exactly (PSR-4) |
| No `_JEXEC` in namespaced files | Namespaced classes under `src/` are autoloaded; the `defined('_JEXEC') or die;` guard goes in entry-point files only (`services/provider.php`, `tmpl/`, etc.) |
| Extension class location | `src/Extension/<Name>Component.php` (or `<Name>Plugin.php`, `<Name>Module.php`) |
| Service provider location | `services/provider.php` — NOT under `src/` (it's the bootstrap, not an autoloaded class) |

## Why

Joomla's autoloader maps the manifest `<namespace>` to two PSR-4 prefixes: `Vendor\Component\Name\Administrator\` → `administrator/components/com_name/src/` and `Vendor\Component\Name\Site\` → `components/com_name/src/`. If the file doesn't match the expected path, Joomla's class loader silently fails and the extension throws a "class not found" fatal error — often only surfaced when a specific admin page or front-end view is hit.

Getting the namespace wrong is the single most common "extension doesn't load" issue reported by Joomla developers.

## What Rex flags

Surface a finding when:

1. A class under `src/` doesn't declare a `namespace` matching the PSR-4 path from manifest.
2. A class filename doesn't match the class name (case-sensitive on Linux).
3. The manifest `<namespace path="src">` is missing or points to the wrong directory.
4. A new class is added under `src/` but uses `defined('_JEXEC') or die;` — this guard is unnecessary in autoloaded namespaced classes and adds dead code.
5. `services/provider.php` is moved into `src/` — it must remain at the expected path for Joomla's boot sequence.
6. A class uses `JLoader::register()` instead of relying on the PSR-4 namespace — legacy pattern, should be migrated.

## Sample finding

> **Namespace (Joomla)** — `administrator/components/com_example/src/Model/ItemModel.php` declares `namespace Acme\Component\Example\Model;` but should be `namespace Acme\Component\Example\Administrator\Model;`. Without the `Administrator` segment, Joomla's autoloader won't find the class, and the admin list view will throw "Class not found".
>
> **Namespace (Joomla)** — `src/Helper/UtilHelper.php` contains `defined('_JEXEC') or die;`. This file is under `src/` and autoloaded via PSR-4; the guard is dead code. Remove it — it only belongs in non-autoloaded entry points like `tmpl/` files.

## What's NOT a violation

- `services/provider.php` using `defined('_JEXEC') or die;` — it's an entry point, not an autoloaded class.
- `tmpl/*.php` files not having namespaces — templates are included, not autoloaded.
- Legacy `JLoader::register()` in a file explicitly marked with a `// @legacy` comment and a migration ticket reference.
- `script.php` (install/update script) at the extension root — it's loaded by the installer, not autoloaded.

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
