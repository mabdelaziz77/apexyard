# Topology: Joomla Extension (Component / Plugin / Module)

**Version**: 1.0.0
**Stack**: PHP 8.2+ + Joomla 5.x / 6.x + PSR-12 + PHPStan + PHPUnit + Composer
**Use this when**: building a Joomla extension (component, plugin, module, or package) that follows the Joomla MVC pattern, uses the DI container, and targets Joomla 5 or 6.

## What this topology bundles

Pick this topology in `/handover` and the skill instantiates:

| Layer | Files instantiated | Where they land |
|-------|--------------------|-----------------|
| Architecture handbooks | `clean-architecture-layers.md`, `migration-safety.md` (always-load, blocking) | `handbooks/architecture/` |
| Language handbooks | `strict-typing.md`, `psr12-style.md`, `namespace-autoloading.md` | `handbooks/language/php/` |
| Domain handbooks | `joomla-di/service-provider.md`, `joomla-security/input-output-safety.md`, `joomla-db/query-builder-safety.md` | `handbooks/domain/<area>/` (each has `paths:` frontmatter) |
| CI pipeline | `joomla-ci.yml` (PHP-CS-Fixer + PHPStan + PHPUnit + extension package build) | `.github/workflows/` |
| AgDR template | `agdr-joomla-extension.md` (extension type, namespace, DB strategy, auth prompts) | `docs/agdr/agdr-joomla-extension.draft.md` |

## Why pick this topology

Joomla 5 and 6 provide a well-defined MVC framework with a DI container, PSR-4 autoloading, event-driven plugin architecture, and built-in security primitives (CSRF tokens, input filtering, output escaping). The **ambient affordances** are high for a PHP CMS extension: the framework enforces manifest-based installation, namespace-rooted class loading, and service-provider registration.

If your codebase is PHP but **not** Joomla (Laravel, Symfony, WordPress), this topology will over-fit. Run `/handover` without picking a topology.

## Ambient affordances this topology assumes

| Affordance | How it's provided | Why it matters to Rex |
|------------|-------------------|------------------------|
| PSR-12 coding standard | `phpcs` / `php-cs-fixer` config in `composer.json` or `.php-cs-fixer.dist.php` | Style handbook can flag violations |
| Strict typing | `declare(strict_types=1);` at top of every PHP file | Type-safety handbook applies |
| Namespace conventions | `<Vendor>\Component\<Name>\{Administrator,Site}\` mapped via manifest `<namespace path="src">` | Namespace handbook can flag mis-mapped classes |
| DI service provider | `services/provider.php` registering the extension in Joomla's container | Service-provider handbook is enforceable |
| Joomla security primitives | `$this->escape()`, `HTMLHelper`, CSRF tokens via `Session::checkToken()`, `$db->quote()` / prepared statements | Security handbook fires on template + model files |
| PHPStan baseline | `phpstan.neon` at repo root with level ≥ 5 | Static analysis gates apply |
| PHPUnit test suite | `phpunit.xml` + `tests/` directory | Test coverage gates apply |

## Files in this bundle

```
joomla-extension/
├── VERSION
├── README.md
├── handbooks/
│   ├── architecture/
│   │   ├── clean-architecture-layers.md
│   │   └── migration-safety.md                              ← blocking (SQL schema migrations)
│   ├── language/
│   │   └── php/
│   │       ├── strict-typing.md
│   │       ├── psr12-style.md
│   │       └── namespace-autoloading.md
│   └── domain/
│       ├── joomla-di/
│       │   └── service-provider.md                          ← paths: **/services/provider.php, **/Extension/**
│       ├── joomla-security/
│       │   └── input-output-safety.md                       ← paths: **/tmpl/**, **/View/**, **/Controller/**
│       └── joomla-db/
│           └── query-builder-safety.md                      ← paths: **/Model/**, **/Table/**, **/sql/**
├── golden-paths/
│   └── joomla-ci.yml
└── templates/
    └── agdr-joomla-extension.md
```
