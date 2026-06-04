ENFORCEMENT: blocking

# Handbook: Migration Safety (Joomla variant)

**Scope:** all PRs in a Joomla extension project.
**Enforcement:** blocking.

## The rule

Every schema change to the Joomla extension's database tables must be captured in a versioned SQL file under the extension's `sql/updates/<driver>/` directory and referenced in the manifest XML's `<update>` section. Migrations must be backwards-compatible for at least one release cycle.

| Required | Pattern |
|---|---|
| SQL update files | One file per version bump under `sql/updates/mysql/` (and `sql/updates/postgresql/` if multi-driver) named `<version>.sql` |
| Manifest reference | `<update><schemas><schemapath type="mysql">sql/updates/mysql</schemapath></schemas></update>` |
| Install SQL | `sql/install.mysql.utf8.sql` contains the full current schema (what a fresh install gets) |
| Uninstall SQL | `sql/uninstall.mysql.utf8.sql` drops the extension's tables cleanly |
| Backwards compatibility | `ALTER TABLE` must not drop columns that existing code reads; add columns as `NULL` or with a `DEFAULT` first; remove them one release later |
| No data loss | `DROP TABLE`, `TRUNCATE`, `DELETE` without `WHERE` are forbidden in update SQL; flag for manual review |

## Why

Joomla's extension update mechanism runs SQL files in version order during `com_installer` updates. A broken migration means every site that updates the extension hits an error — and Joomla has no built-in rollback. The SQL runs once, inline, in the same request as the extension update. A `DROP COLUMN` that existing code still references produces a fatal error on every page load until the admin manually patches the database.

Backwards compatibility for one release gives site administrators a safe upgrade window: update the extension, verify it works, then update again to the release that drops the deprecated column.

## What Rex flags

Surface a finding when:

1. A PR adds or modifies a file under `src/Table/` or `forms/` that references a new column, but no corresponding `sql/updates/<driver>/<version>.sql` file exists in the PR.
2. An update SQL file contains `DROP TABLE`, `DROP COLUMN`, `TRUNCATE`, or `DELETE` without a `WHERE` clause.
3. The manifest XML's `<update><schemas>` section doesn't reference the `sql/updates/` path.
4. A new column is added as `NOT NULL` without a `DEFAULT` value — existing rows will fail the `ALTER TABLE`.
5. The install SQL (`sql/install.mysql.utf8.sql`) is not updated to reflect the new schema.
6. An update SQL file changes a column type in a way that could truncate data (e.g., `VARCHAR(255)` to `VARCHAR(50)`).

## Sample finding

> **Migration safety (Joomla)** — PR adds `$this->getTable('Item')` referencing column `priority` in `src/Table/ItemTable.php`, but no `sql/updates/mysql/<version>.sql` with `ALTER TABLE #__example_items ADD COLUMN priority` exists. Site administrators who update the extension will get a SQL error on every page that touches this table. Add the migration SQL and update the install SQL.

## What's NOT a violation

- Adding a new table entirely (as long as both install SQL and update SQL contain the `CREATE TABLE`).
- `DROP TABLE` in `sql/uninstall.mysql.utf8.sql` — that's the correct place for cleanup.
- Test fixtures that create/drop temporary tables in `tests/`.
- `ALTER TABLE` that adds a `NULL` column with a default — that's the safe pattern.

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
