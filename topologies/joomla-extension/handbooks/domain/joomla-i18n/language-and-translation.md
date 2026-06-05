---
paths:
  - "**/language/**"
  - "**/*.ini"
  - "**/tmpl/**"
  - "**/src/**"
  - "**/*.xml"
---

# Handbook: Language & Translation (Joomla variant)

**Scope:** PRs touching language INI files, templates/views that output text, or the manifest.
**Enforcement:** advisory.

## The rule

Every user-facing string is a translatable language key — never a hardcoded literal. Strings live in INI files keyed by an UPPERCASE, extension-prefixed constant, and are emitted through Joomla's `Text::` API. This is verified against Joomla core (`com_contact`, `com_banners`) and the JEDChecker `LanguageRule`.

### File layout

| File | Holds | Loaded |
|---|---|---|
| `language/xx-XX/xx-XX.com_name.ini` | Runtime strings (front-end + admin UI) | When the extension renders |
| `language/xx-XX/xx-XX.com_name.sys.ini` | Install-time + listing strings (extension display name, menu labels, the manifest `<description>` key) | Before the extension boots — by the installer and the admin extension list |

- `xx-XX` is the Joomla language tag: two/three lowercase letters, dash, two uppercase letters (`en-GB`, `de-DE`, `pt-BR`). The `.sys.ini` is **mandatory** — the extension's name shows as the raw key in the installer without it.
- Modules/plugins follow the same pattern (`mod_name.ini` / `mod_name.sys.ini`, `plg_group_name.ini` / `.sys.ini`).

### INI key conventions (JEDChecker `LanguageRule` enforces these)

| Required | Pattern |
|---|---|
| Prefix | Every key starts with the extension's uppercase prefix: `COM_EXAMPLE_`, `MOD_JRSHOWCASE_`, `PLG_SYSTEM_EXAMPLE_` |
| Case | Keys are **UPPERCASE** (`COM_EXAMPLE_TITLE`, not `com_example_title`) — JEDChecker warns otherwise |
| Charset | Key names are **ASCII**; no whitespace; none of `{ } | & ~ ! [ ( ) ^ "` — JEDChecker errors |
| Uniqueness | No duplicate keys within a file — JEDChecker errors on a redeclaration |
| Values | Double-quoted: `COM_EXAMPLE_TITLE="Title"`. A literal `"` inside a value is `"_QQ_"` (legacy) or `\"` (Joomla 3.9+) |
| Encoding | **UTF-8 without BOM** — JEDChecker warns on a BOM; core ini headers carry `; Note : All ini files need to be saved as UTF-8` |
| Header | A comment header with the GPL license line (mirrors core ini files) |

### Emitting strings in PHP

| API | Use |
|---|---|
| `Text::_('COM_EXAMPLE_TITLE')` | Plain string |
| `Text::sprintf('COM_EXAMPLE_N_ITEMS', $count)` | Interpolated (`%d`, `%s`) |
| `Text::plural('COM_EXAMPLE_N_ITEMS', $count)` | Plural forms (`_0`, `_1`, … suffixed keys) |
| `Text::script('COM_EXAMPLE_CONFIRM')` | Push a key to JS — read client-side via `Joomla.Text._('COM_EXAMPLE_CONFIRM')` |

`use Joomla\CMS\Language\Text;` at the top. `Text::_()` output is also XSS-safe for developer-authored keys (see the input/output-safety handbook), so a translated label doesn't need re-escaping — but interpolated user data still does.

### Manifest + loading

- Register language files in the manifest `<languages>` block (the installer copies them):
  ```xml
  <languages>
    <language tag="en-GB">language/en-GB/en-GB.com_example.ini</language>
    <language tag="en-GB">language/en-GB/en-GB.com_example.sys.ini</language>
  </languages>
  ```
- Joomla autoloads the component/module/plugin language on dispatch. Load an *extra* file explicitly with `$app->getLanguage()->load('com_example', JPATH_ADMINISTRATOR)`.

### Multilingual sites (content, not just UI)

- Tag content items with a language; provide an **Associations** field so equivalents in other languages link up.
- The "Language Filter" system plugin drives front-end switching; SEF routing keys off the language code.
- Don't assume a single site language — read it via `$app->getLanguage()->getTag()` rather than hardcoding `en-GB`.

## Why

A hardcoded `"Read more"` can't be translated, fails JED's `LanguageRule`, and breaks every non-English site. Joomla's whole extension ecosystem is i18n-first: the `.sys.ini` is what makes an extension show a human name in the installer, and the key conventions are exactly what JEDChecker validates before a JED listing is allowed. Getting language wrong is both a UX failure and a JED-rejection cause.

## What Rex flags

Surface a finding when:

1. A user-facing literal string is output directly (`echo 'Save';`, `<th>Title</th>`) instead of `Text::_('PREFIX_...')`.
2. A new INI key is lowercase, has whitespace/special characters, or isn't prefixed with the extension's constant.
3. A duplicate INI key is added within the same file.
4. A `.sys.ini` is missing for a new component/module/plugin (the installer will show the raw key).
5. An INI value is unquoted or has an unescaped `"`.
6. A language file is added but not registered in the manifest `<languages>` block.
7. A JS string is hardcoded in a `.js` file instead of pushed via `Text::script()` + `Joomla.Text._()`.
8. Code hardcodes `en-GB` (or assumes a single language) instead of reading the active language tag.

## Sample finding

> **Language (Joomla)** — `tmpl/default.php:18` outputs `<h3>Featured</h3>`. Hardcoded UI strings aren't translatable and fail JED's LanguageRule. Add `MOD_JRSHOWCASE_FEATURED="Featured"` to `language/en-GB/en-GB.mod_jrshowcase.ini` and emit `<h3><?php echo Text::_('MOD_JRSHOWCASE_FEATURED'); ?></h3>`.
>
> **Language (Joomla)** — `language/en-GB/en-GB.com_example.ini:42` declares `Com_Example_List = "List"`. JEDChecker requires UPPERCASE keys, no spaces around `=`, and a quoted value. Use `COM_EXAMPLE_LIST="List"`.

## What's NOT a violation

- Non-translatable tokens: numeric IDs, CSS classes, HTML attribute names, machine keys.
- `Text::_()` of a developer-authored key without re-escaping — translation constants are safe output.
- A single language file shipped (en-GB only) — additional translations are community-contributed; shipping just the source language is fine.
- Third-party `vendor/` strings.
- Debug/log messages not shown to end users (advisory at most).

## Related

- `joomla-jed/jed-listing-readiness.md` — the `LanguageRule` is a JED gate; this handbook is its detail.
- `joomla-security/input-output-safety.md` — `Text::_()` output safety + escaping interpolated user data.

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
