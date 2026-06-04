---
paths:
  - "**/Model/**"
  - "**/Table/**"
  - "**/src/Model/**"
  - "**/src/Table/**"
  - "**/sql/**"
---

# Handbook: Query Builder Safety (Joomla variant)

**Scope:** PRs touching Models, Tables, or SQL files in a Joomla extension.
**Enforcement:** advisory.

## The rule

All database queries use Joomla's query builder with proper value escaping. No raw SQL string concatenation with user-supplied data.

| Required | Pattern |
|---|---|
| Query builder usage | `$db->getQuery(true)` to start every query |
| String value escaping | `$db->quote($value)` for all string literals in `WHERE`, `SET`, `VALUES` |
| Column/table name quoting | `$db->quoteName('column_name')` for identifiers |
| Integer casting | `(int) $value` for numeric comparisons — never rely on `quote()` for integers |
| Prepared statements | `$query->bind(':id', $id, ParameterType::INTEGER)` with `$query->where($db->quoteName('id') . ' = :id')` — preferred for Joomla 4+ |
| Table prefix | `#__` prefix for all Joomla tables; never hardcode `jos_` or any other prefix |
| `IN` clauses | Use `$query->whereIn($db->quoteName('id'), $ids)` or quote each value individually — never implode unescaped |

| Anti-pattern | Why it's dangerous |
|---|---|
| `"WHERE id = " . $input` | SQL injection — `$input` could be `1 OR 1=1` |
| `$db->setQuery("DELETE FROM #__items WHERE id = $id")` | Raw SQL with variable interpolation — injection vector |
| `$db->quote($intValue)` for integer comparisons | Quote wraps in strings; MySQL may skip an index; use `(int)` cast instead |
| `$query->where("title LIKE '%" . $search . "%'")` | Unescaped LIKE — injection vector; use `$db->quote('%' . $db->escape($search, true) . '%', false)` |

## Why

SQL injection in Joomla extensions is the highest-severity vulnerability class. A single unescaped `$_GET['id']` in a `WHERE` clause can dump the entire database — user credentials, session tokens, configuration secrets. Joomla's query builder and prepared statements eliminate this class of bugs when used consistently.

The query builder also handles database driver differences (MySQL vs PostgreSQL) transparently. Raw SQL that works on MySQL may fail on PostgreSQL, breaking multi-driver compatibility.

## What Rex flags

Surface a finding when:

1. A query string is built via concatenation with a variable that originates from user input (`$app->input->get*()`, `$_GET`, `$_POST`, function parameters).
2. `$db->setQuery("...")` contains interpolated PHP variables without `$db->quote()` or `$db->quoteName()`.
3. A `WHERE` clause uses a bare variable without casting (`(int)`) or quoting (`$db->quote()`).
4. A `LIKE` clause uses user input without `$db->escape($value, true)`.
5. `$db->quote()` is used for an integer comparison instead of `(int)` casting.
6. Table names are hardcoded with a specific prefix (`jos_`) instead of using `#__`.
7. A raw SQL string appears in a Model or Table class instead of using the query builder.
8. An `IN` clause implodes an array without quoting each element.

## Sample finding

> **Query builder safety (Joomla)** — `src/Model/ItemsModel.php:42` builds a WHERE clause via `$query->where('category_id = ' . $categoryId)` where `$categoryId` comes from `$app->input->getInt('catid')`. Even though `getInt()` filters to integer, the pattern is fragile — a future refactor might pass an unfiltered value. Use a prepared statement: `$query->where($db->quoteName('category_id') . ' = :catid')->bind(':catid', $categoryId, ParameterType::INTEGER)`.
>
> **Query builder safety (Joomla)** — `src/Model/SearchModel.php:28` builds `$query->where('title LIKE \'%' . $search . '%\'')` with unescaped `$search`. This is a SQL injection vector. Use `$query->where($db->quoteName('title') . ' LIKE :search')->bind(':search', '%' . $search . '%')`.

## What's NOT a violation

- Hardcoded constant values in queries: `$query->where($db->quoteName('state') . ' = 1')` — no user input involved.
- SQL files under `sql/install.*.sql` and `sql/updates/` — these contain DDL with no runtime user input.
- `$db->escape()` used correctly inside a `LIKE` with the second parameter `true` (to also escape `%` and `_`).
- Queries in test fixtures under `tests/` that use known test data.

## Pattern — safe query with prepared statements (Joomla 4+)

```php
$db = $this->getDatabase();
$query = $db->getQuery(true);

$query->select($db->quoteName(['id', 'title', 'state']))
    ->from($db->quoteName('#__example_items'))
    ->where($db->quoteName('category_id') . ' = :catid')
    ->where($db->quoteName('state') . ' = 1')
    ->order($db->quoteName('ordering') . ' ASC')
    ->bind(':catid', $categoryId, ParameterType::INTEGER);

$db->setQuery($query);
$items = $db->loadObjectList();
```

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
