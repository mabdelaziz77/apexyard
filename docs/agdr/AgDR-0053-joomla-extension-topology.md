# Add `joomla-extension` as a fork-local topology ahead of the upstream demand gate

> In the context of adopting `mod_jrshowcase` (a Joomla 5 PHP module) into the portfolio and finding no topology that fits a PHP/Joomla CMS extension, facing the fact that upstream (`me2resh/apexyard`) deliberately gates new topologies behind a 5-adopter demand signal (AgDR-0048 § "Out of scope", README anti-proliferation per #297), I decided to add a `joomla-extension` topology **fork-locally** — committed to this fork and wired into `/handover` here, but not PR'd upstream — to achieve a correct governance surface for the Joomla extension we are actually governing now, accepting that the bundle lives outside the upstream-curated set and will surface as drift on the next `/update`.

## Context

The `mod_jrshowcase` handover (registered 2026-06-05, harnessability `low`) surfaced the core gap a topology exists to close: with no PHP/Joomla topology, Rex loads the TS-oriented default architecture handbooks against a PHP codebase, generating false-positive review noise. A `joomla-extension` bundle (8 handbooks across `architecture/` + `language/php/` + `domain/joomla-*`, a Joomla CI pipeline, and a stack-specific AgDR template) already existed on disk but was untracked and reachable only via the `--topology joomla-extension` flag — invisible in the interactive `/handover` menu.

AgDR-0048 established the topology system with three framework-curated starters (typescript-nextjs, python-fastapi, go-data-pipeline) and explicitly deferred adopter-authored topologies to v2.1, gating new upstream topologies behind a 5-adopter demand signal. We have exactly one adopter (this fork) asking for Joomla — well below that gate. The decision is therefore not "should upstream add this" but "how do we get a correct harness for our Joomla project now, without violating the upstream curation policy".

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| **Fork-local topology (chosen)** | Correct governance surface for `mod_jrshowcase` immediately; respects upstream's 5-adopter gate; `--topology` flag already works, only menu-wiring needed | Touches upstream-owned files (`topologies/README.md`, `handover/SKILL.md`) → `/update` drift; bundle maintained locally |
| Leave it flag-only (no wiring) | Zero drift; no upstream-file edits | Topology stays invisible; every operator must already know the flag exists — the discoverability gap that prompted the ticket |
| PR it upstream now | Shared with all adopters; no local maintenance | Premature by upstream's own policy (1/5 adopters); likely rejected or stalled |
| No topology; advisory-only handbooks | Simplest | Doesn't fix the false-positive noise; re-litigates the problem AgDR-0048 already solved for other stacks |

## Decision

Chosen: **fork-local topology**, because it delivers the correct harness for a project we are governing today while honouring upstream's anti-proliferation gate. The right upstream move — if Joomla demand accumulates — is a separate feature *issue* to seed the 5-adopter signal, not a premature bundle PR.

## Consequences

- `topologies/joomla-extension/` becomes tracked; `/handover` lists it as pick `[4]` (Skip/custom → `[5]`).
- Edits to `topologies/README.md` and `.claude/skills/handover/SKILL.md` are upstream-owned → expect drift flags on the next `/update`. Acceptable and documented here.
- The bundle is maintained in this fork until/unless it is upstreamed.
- If ≥ 5 adopters request Joomla upstream, revisit and promote the bundle via the normal upstream feature-ticket path.

## Artifacts

- Ticket: mabdelaziz77/apexyard#1
- Builds on: [AgDR-0048](AgDR-0048-topology-templates.md) (topology system)
- Bundle: `topologies/joomla-extension/` (12 files)
