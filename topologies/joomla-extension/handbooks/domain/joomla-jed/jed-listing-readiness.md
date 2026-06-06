---
paths:
  - "**/*.php"
  - "**/*.xml"
  - "**/*.ini"
---

# Handbook: JED Listing Readiness (Joomla variant)

**Scope:** PRs on an extension intended for the Joomla Extensions Directory (JED).
**Enforcement:** advisory.

## The rule

An extension that will be listed on the [JED](https://extensions.joomla.org) must pass **JEDChecker** ([joomla-extensions/jedchecker](https://github.com/joomla-extensions/jedchecker)) — the official validation component. This handbook tracks JEDChecker's actual rules (read from its `develop` branch) so problems are caught during development, not at submission.

> **How JEDChecker actually runs.** JEDChecker is a Joomla **admin component**, not a CLI or CI tool — there is no standalone binary or reusable GitHub Action (its repo ships only a Crowdin translation workflow). To run the real check: install the JEDChecker component on a Joomla test site, point it at the extension, and read the report. The bundle's `joomla-ci.yml` adds a `jed-readiness` job that **proxies** the cheapest-to-automate rules below — it is a fast pre-flight, **not** a substitute for running JEDChecker before submission.

## The JEDChecker rules

| Rule | What it requires | Severity |
|---|---|---|
| **GplRule** (PH1) | Every PHP file carries a GPL (or JED-accepted compatible) license notice in its header | required |
| **JexecRule** (PH2) | Every PHP file begins with `defined('_JEXEC') or die;` so it can't be run outside Joomla | required |
| **ErrorReportingRule** | No `error_reporting(0)` / forced `@`-suppression — Joomla owns error reporting via Global Config | required |
| **SecurityRule** | No obfuscated loaders (IonCube, Zend Guard, SourceGuardian — not GPL-compatible); no executables (`.exe`, `.bin`, `.so`, `.dll`); no shell scripts (`.sh` / shebang); no files with spaces/special chars in the name | required |
| **FrameworkRule** | No PHP superglobals (`$_GET`/`$_POST`/`$_REQUEST` directly), no deprecated/unsafe functions — use the Joomla API (`$app->getInput()`, etc.) | warning |
| **LanguageRule** | Language INI files valid: UPPERCASE ASCII keys, no whitespace/special chars, no duplicates, no BOM, quoted values (see `joomla-i18n/language-and-translation.md`) | error/warning |
| **XmlManifestRule** | The XML manifest is well-formed and complete | required |
| **XmlInfoRule** | The manifest `<name>` (install name) **matches the JED listing name** | required |
| **EncodingRule** | Files are UTF-8 | warning |
| **JamssRule** | Passes the Joomla Anti-Malware Scan Script (no known-malicious signatures) | required |

GPL is non-negotiable: JED only lists GPL-or-compatible code. Encrypted/obfuscated distributions are rejected outright by `SecurityRule`.

## Why

Failing JEDChecker means the extension can't be published on the JED — the primary distribution channel for the Joomla ecosystem. Most failures are cheap to fix during development (a missing license header, a `_JEXEC` guard, a non-uppercase language key) but expensive at submission time, where they bounce the listing and cost a review round-trip. Catching them on every PR keeps the extension permanently submission-ready.

## What Rex flags

Surface a finding when:

1. A new `*.php` file is **missing** the `defined('_JEXEC') or die;` guard (cf. `joomla-jed` JexecRule + the namespace handbook — core keeps it in every `src/` file, wrapped in `// phpcs:disable PSR1.Files.SideEffects`).
2. A new `*.php` file has **no GPL license header**.
3. `error_reporting(0)` or a blanket `@`-suppressed call to a risky function appears.
4. An obfuscated/encoded payload, an executable, or a shell script is added to the extension tree.
5. A superglobal (`$_GET`/`$_POST`/`$_REQUEST`/`$_SERVER`) is read directly instead of via `$app->getInput()`.
6. The manifest `<name>` is changed in a way that would diverge from the JED listing name.
7. A language-file issue that `LanguageRule` would flag (defer detail to the i18n handbook).

## Sample finding

> **JED readiness (Joomla)** — `src/Helper/ExportHelper.php` has no `defined('_JEXEC') or die;` guard and no GPL header. JEDChecker's JexecRule and GplRule both require these on every PHP file; the listing would bounce. Add the GPL header comment and the guard (wrapped per the namespace handbook).
>
> **JED readiness (Joomla)** — `src/Controller/ApiController.php:30` reads `$_POST['payload']` directly. JEDChecker's FrameworkRule flags superglobals. Use `$this->app->getInput()->post->get('payload', '', 'raw')` and filter appropriately.

## What's NOT a violation

- Extensions **not** intended for the JED (private/in-house) — this whole handbook is opt-in for JED-bound work. If the project isn't headed to the JED, treat every finding here as informational.
- `vendor/` third-party code — JEDChecker scans it, but its license/headers are upstream's concern; document third-party licenses in the manifest instead of editing vendor headers.
- A deliberate, documented `@`-suppression on a single call with a comment explaining why (FrameworkRule is a warning, not a hard fail).
- Test files under `tests/`.

## Release packaging + JED submission (per release)

The topology ships three release artifacts (copy them into your extension repo):

| Artifact | Copy to | What it does |
|----------|---------|--------------|
| `golden-paths/build.sh` | `build/build.sh` | Manifest-driven package builder — reads the extension name + `<version>` and produces a clean `dist/<ext>-<version>.zip` (excludes VCS/dev files). This is the artifact you feed to **JEDChecker** and upload to Joomla. |
| `golden-paths/release.yml` | `.github/workflows/release.yml` | On a `v*` tag, runs `build.sh` and attaches the zip to the GitHub Release. |
| `templates/jed-submission.md` | `docs/jed-submission.md` | The JED listing form metadata — fill it in once, keep it current each release. |

The per-release flow:

1. Bump the manifest `<version>`; update `docs/jed-submission.md`.
2. `bash build/build.sh` → `dist/<ext>-<version>.zip`.
3. Run the **JEDChecker** component against the zip on a Joomla test site; fix any findings (the rules above + the `jed-readiness` CI proxy catch most pre-flight).
4. Smoke-test on a clean Joomla install.
5. Tag `vX.Y.Z` (the release workflow publishes the asset) and submit/update the JED listing from `docs/jed-submission.md`.

Add `dist/` to `.gitignore` — the package is a build output, never committed (the old "commit the zip" habit causes version drift).

## Related

- `joomla-i18n/language-and-translation.md` — the LanguageRule detail.
- `language/php/namespace-autoloading.md` — the `_JEXEC` guard (JexecRule corroborates it).
- `joomla-security/input-output-safety.md` — superglobal avoidance + input filtering (FrameworkRule).

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
