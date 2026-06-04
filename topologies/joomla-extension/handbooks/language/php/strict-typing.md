# Handbook: Strict Typing (Joomla PHP variant)

**Scope:** PRs touching `**/*.php` files in a Joomla extension project.
**Enforcement:** advisory.

## The rule

Every PHP file in this extension declares `strict_types` and uses type hints on all public method signatures and class properties.

| Required | Pattern |
|---|---|
| Strict types declaration | `declare(strict_types=1);` as the first statement after `<?php` in every file |
| Function return types | `public function getItems(): array` — no bare `public function getItems()` |
| Parameter types | `public function save(ItemEntity $item): bool` — no untyped parameters |
| Property types | `private DatabaseInterface $db;` — no untyped class properties (PHP 8.2+ allows all types) |
| Union types | `string\|null` preferred over `?string` for consistency; both acceptable |
| `mixed` usage | Only with a docblock explaining why a concrete type isn't possible |
| PHPStan level | Minimum level 5 in `phpstan.neon`; level 8+ recommended for new extensions |

## Why

PHP's type system is opt-in. Without `strict_types`, PHP silently coerces `"123abc"` to `123` when passed to an `int` parameter — a class of bugs that surfaces only at runtime, often in production. Joomla 5+ requires PHP 8.1+; Joomla 6 requires PHP 8.2+. Both support all modern type features (union types, intersection types, `readonly`, enums). There's no technical reason to skip type hints.

Joomla's own codebase is migrating toward stricter typing. Extensions that match this trajectory are easier to maintain alongside core updates and benefit from PHPStan catching type errors before deployment.

## What Rex flags

Surface a finding when:

1. A new PHP file is added without `declare(strict_types=1);` as the first statement.
2. A public method in a class under `src/` lacks a return type declaration.
3. A public method parameter has no type hint.
4. A class property is declared without a type (`public $items;` instead of `public array $items`).
5. `mixed` is used without a docblock justification.
6. `phpstan.neon` level is reduced below 5 or the file is removed.
7. A `@phpstan-ignore` annotation is added without a comment explaining the reason.

## Sample finding

> **Strict typing (PHP)** — `src/Model/ItemModel.php:24` declares `public function getItem($id)` — no parameter type, no return type. Add `public function getItem(int $id): ?object` (or a concrete return type). Without types, PHPStan can't verify callers pass the right argument, and Joomla's FormModel methods won't benefit from strict dispatch.
>
> **Strict typing (PHP)** — `src/Controller/ItemController.php` is missing `declare(strict_types=1);`. Add it as the first statement after `<?php`.

## What's NOT a violation

- Files that only contain `<?php defined('_JEXEC') or die;` and a `return` (e.g., short entry-point guards in legacy extensions) — these are structural, not logic files.
- Generated code (Joomla install scripts, XML form definitions) — out of scope.
- Test files under `tests/` — PHPUnit fixtures often use dynamic types; advisory only.
- `mixed` for Joomla API methods that genuinely return `mixed` (e.g., `$app->input->get()` return values before filtering) — must have a docblock.
- Legacy code touched only for a one-line fix — flag but don't block; track the file for a future cleanup pass.

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
