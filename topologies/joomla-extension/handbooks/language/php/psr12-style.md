# Handbook: PSR-12 Coding Style (Joomla PHP variant)

**Scope:** PRs touching `**/*.php` files in a Joomla extension project.
**Enforcement:** advisory.

## The rule

All PHP code follows PSR-12 (the coding standard Joomla adopted since 4.2). The project enforces this via `phpcs` with the `Joomla` ruleset or `php-cs-fixer` with PSR-12 rules.

| Required | Pattern |
|---|---|
| Indentation | 4 spaces, no tabs |
| Line length | Soft limit 120 chars; hard limit none (but readability matters) |
| Braces | Opening brace on the same line for control structures; next line for class/method declarations |
| `use` statements | One `use` per line; grouped by type (classes, functions, constants); sorted alphabetically within each group |
| Short array syntax | `[]` not `array()` — Joomla requires short syntax since 4.0 |
| Visibility | Every class method and property must declare visibility (`public`, `protected`, `private`) |
| Keywords | PHP keywords (`true`, `false`, `null`, `array`, `int`, `string`) in lowercase |
| Namespace declaration | One blank line after `namespace` before `use` statements |
| Global variables | Forbidden. Use static class properties, constants, or DI instead |

## Why

Joomla core has fully migrated to PSR-12. The older custom Joomla coding standard was archived in March 2024 and receives no maintenance. Extensions that diverge from PSR-12 create friction in PRs (noise from style-only changes mixed with logic), confuse contributors familiar with core conventions, and can't use Joomla's built-in code sniffer (`libraries/vendor/bin/phpcs`) without configuration overrides.

Consistent style also makes automated review easier — Rex can focus on logic instead of formatting.

## What Rex flags

Surface a finding when:

1. A PR introduces PHP files with tab indentation instead of 4-space indentation.
2. A class method or property is missing an explicit visibility keyword.
3. `array()` syntax is used instead of `[]`.
4. `use` statements are not sorted or grouped.
5. A global variable (`$GLOBALS` or an undeclared `global` keyword) is introduced.
6. The project's `phpcs` or `php-cs-fixer` configuration is weakened or removed.

## Sample finding

> **PSR-12 style (PHP)** — `src/Helper/ExampleHelper.php:12` uses `array()` syntax. Joomla requires short array syntax `[]` since 4.0. Run `phpcbf` to auto-fix.
>
> **PSR-12 style (PHP)** — `src/Model/ItemModel.php:30` declares `function getList()` without a visibility keyword. Add `public`, `protected`, or `private`.

## What's NOT a violation

- Third-party library code under `vendor/` — not our code to style.
- XML form definitions and SQL files — PSR-12 applies to PHP only.
- Template files (`tmpl/`) that mix HTML and PHP — PSR-12 applies to the PHP portions; HTML formatting follows its own conventions.
- Minor style preferences not covered by PSR-12 (e.g., trailing commas in multi-line arrays) — advisory at most.

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
