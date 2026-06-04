# {Short Title — e.g. "Choosing the database access pattern for com_inventory"}

> In the context of {context — Joomla extension project, what feature drove the decision}, facing {concern — e.g. "need to support both Joomla 5 and 6 with a single codebase"}, I decided {decision — e.g. "use prepared statements via the query builder exclusively"} to achieve {goal — e.g. "SQL injection prevention and multi-driver compatibility"}, accepting {tradeoff — e.g. "legacy raw-SQL helpers must be rewritten; more verbose query construction"}.

## Context

{Decision-relevant context only. What part of the Joomla stack triggered this? Extension type (component/plugin/module/package), target Joomla version (5.x / 6.x), namespace strategy, database driver?}

## Options Considered

> ApexYard's Joomla-extension topology v1.0.0 ships this template with stack-specific option prompts. Fill in the rows that apply; delete the rest. Don't feel obliged to consider every option — pick the 2-3 that were genuinely on the table.

### A) Extension type & packaging

| Option | Pros | Cons | Picked? |
|--------|------|------|---------|
| **Standalone component** | Full MVC, admin + site, own menu item | Heaviest extension type; overkill for small features | |
| **System plugin** | Lightweight, event-driven, no admin UI needed | No own data model; can't manage content directly | |
| **Content plugin** | Fires on article events; great for content augmentation | Limited to content context; no standalone pages | |
| **Site module** | Small, position-based, easy to configure | No admin-side management; limited MVC support | |
| **Package** (component + plugin + module) | Ships a complete feature as one installable unit | More complex manifest; coordinated versioning | |
| **Library** | Reusable code shared across extensions | No UI; needs a consuming extension to surface features | |

### B) Database access strategy

| Option | Pros | Cons | Picked? |
|--------|------|------|---------|
| **Query builder + prepared statements** | SQL injection safe, multi-driver compatible, Joomla standard | More verbose than raw SQL | |
| **Query builder + quote/escape** | Familiar, slightly less verbose | Not as safe as prepared statements; driver-specific edge cases | |
| **Joomla Table class (active record)** | Single-row CRUD is trivial; built-in check/store/delete | Not suited for complex queries or bulk operations | |
| **Raw SQL strings** | Maximum flexibility | SQL injection risk; breaks multi-driver; hard to maintain | |

### C) Joomla version compatibility

| Option | Pros | Cons | Picked? |
|--------|------|------|---------|
| **Joomla 5 only (5.x LTS)** | Stable API, long support window | Misses Joomla 6 improvements | |
| **Joomla 6 only** | Latest features, cleaner APIs | Cuts off Joomla 5 sites | |
| **Joomla 5 + 6 dual support** | Maximum reach | Must avoid Joomla 6-only APIs; test on both versions | |
| **Joomla 6 + forward (6.x → 7.x)** | Future-proof | Must avoid deprecated APIs scheduled for removal in 7.0 | |

### D) Testing strategy

| Option | Pros | Cons | Picked? |
|--------|------|------|---------|
| **PHPUnit unit tests (isolated, no Joomla)** | Fast, no dependencies, runs in CI | Can't test Joomla integration; needs mocking | |
| **PHPUnit integration tests (with Joomla bootstrap)** | Tests real interaction with Joomla APIs | Slower; needs Joomla install in CI; more complex setup | |
| **Cypress end-to-end** | Tests full user workflows in browser | Slowest; flaky on CI; needs running Joomla site | |
| **PHPStan only (no runtime tests)** | Zero test maintenance; catches type errors and deprecations | Can't verify runtime behaviour or business logic | |
| **Combined: PHPUnit unit + PHPStan + Cypress smoke** | Best coverage pyramid | Most CI setup effort | |

### E) Deployment / distribution

| Option | Pros | Cons | Picked? |
|--------|------|------|---------|
| **JED (Joomla Extensions Directory)** | Discoverability, trust, one-click install from admin | Review process; listing requirements | |
| **GitHub Releases** | CI-driven; version-controlled; update server via XML | Users must add update URL manually | |
| **Private distribution (client-specific)** | Full control; no public listing | No discoverability; manual update process | |
| **Composer package** | Modern PHP workflow; Joomla supports Composer since 4.0 | Non-standard for Joomla end-users; needs `composer require` | |

## Decision

Chosen: **{the option}**, because {2-3 sentences naming the load-bearing reason. Reference the topology's ambient affordances if applicable — e.g. "topology assumes PSR-12 + PHPStan level 5; staying with the query builder keeps the query-safety handbook enforceable"}.

## Consequences

- {Specific consequence for the codebase}
- {Consequence for dev workflow — testing, packaging, release process}
- {Consequence for Joomla version support}
- {Consequence for end-user installation}

## Artifacts

- {Commit / PR links}
- {Updated configs — `composer.json`, `phpstan.neon`, manifest XML}
- {Affected handbooks}

## What this decision does NOT cover

- {Be explicit about scope}
- {Future AgDRs if applicable}
