# Topologies — harness templates per service shape

A **topology** is a common service shape (web app, API service, data pipeline) that ApexYard knows how to harness opinionatedly. Each topology bundles the framework primitives an adopter would otherwise reassemble by hand on every onboarding: handbooks, CI pipelines, and stack-specific AgDR templates.

Design rationale: [`docs/agdr/AgDR-0048-topology-templates.md`](../docs/agdr/AgDR-0048-topology-templates.md).

> **Pick a topology when running `/handover`.** The skill asks early in its flow; on pick, it copies the bundle into the new project. Default is "Skip / custom" — adopters who don't want a bundle get the existing flow byte-for-byte.

## The three starter topologies (v1)

| Topology | Use when | Ambient affordances | Primary language |
|----------|----------|---------------------|------------------|
| [`typescript-nextjs`](typescript-nextjs/) | Building a SaaS web app with API routes, server components, and a relational DB | TS strict + Next.js conventions + ORM opinionation | TypeScript |
| [`python-fastapi`](python-fastapi/) | Building an HTTP service with persistence, JWT auth, and OpenAPI docs | Python type hints + Pydantic validation + FastAPI conventions | Python |
| [`go-data-pipeline`](go-data-pipeline/) | Building a batch or streaming pipeline (ETL, event processor) with no HTTP surface | Go's enforced error returns + module boundaries + stdlib-first | Go |

### Fork-local additions

These topologies live in this fork only — they are **not** part of the upstream framework-curated set, and were added ahead of upstream's 5-adopter demand gate to govern a concrete project. Expect them to surface as drift on the next `/update`.

| Topology | Use when | Ambient affordances | Primary language | Decision |
|----------|----------|---------------------|------------------|----------|
| [`joomla-extension`](joomla-extension/) | Building a Joomla 5–6 extension (component / plugin / module) using the MVC pattern + DI container | PSR-12 + strict typing + Joomla security primitives (escaping, CSRF, prepared statements) | PHP | [AgDR-0053](../docs/agdr/AgDR-0053-joomla-extension-topology.md) |

If your project doesn't match any of the above, run `/handover` without picking a topology — you'll get the existing flow plus the framework's default handbooks (the universal layer applies regardless).

## Directory shape

Every topology mirrors the framework's own primitive layout — path IS the discovery metadata, same convention as `handbooks/<bucket>/` and `templates/custom-templates/<path>` (see AgDR-0020 + AgDR-0023):

```
topologies/<name>/
├── VERSION                       ← semver string, "1.0.0" to start
├── README.md                     ← what this topology is for, when to pick it
├── handbooks/
│   ├── architecture/*.md         ← curated subset of handbooks/architecture/
│   ├── language/<lang>/*.md      ← stack-specific (typescript/, python/, go/)
│   └── domain/<area>/*.md        ← ≥ 3 concrete domain handbooks with paths: frontmatter
├── golden-paths/*.yml            ← stack-specific CI workflows
└── templates/agdr-<stack>.md     ← stack-specific AgDR template prompts
```

## Adding a new topology (framework PR)

v1 is **framework-curated only** — adopter-authored topologies are deferred to v2.1 (see AgDR-0048 § "Out of scope"). To propose a new topology:

1. File a feature ticket against `me2resh/apexyard` with the topology name and the stack it covers
2. Wait until at least 5 adopters have asked for the same shape (mitigates topology proliferation per #297)
3. Open a framework PR that adds `topologies/<name>/` with the directory shape above
4. Bump the topology's `VERSION` per the rules below; first PR is `1.0.0`

**Fork-local exception.** A fork may add a topology to its own copy *ahead of* the 5-adopter upstream gate when it has a concrete project to govern — wired into the fork's `/handover` and `README.md` but not PR'd upstream. Record the deviation in an AgDR. `joomla-extension` (added for `mod_jrshowcase`, see [AgDR-0053](../docs/agdr/AgDR-0053-joomla-extension-topology.md)) is the reference example. If upstream demand later reaches the gate, promote the bundle via the normal path above.

## Versioning

Each topology has its own `VERSION` file with a semver string. Bump rules:

| Change | Bump |
|--------|------|
| Add a new file (handbook, pipeline, template) | minor |
| Edit an existing file (clarify a rule, update a pipeline step) | patch |
| Remove a file (delete a handbook, drop a pipeline) | major (breaks adopter expectations) |
| New topology, first ship | `1.0.0` |

When an adopter runs `/update`, the skill diffs the framework's topology `VERSION` against the adopter's instantiated `VERSION` (copied at handover time). On drift, it offers per-file re-instantiation. See `.claude/skills/update/SKILL.md` § "Topology drift detection".

## Out of scope (v1)

- Adopter-authored topologies — v2.1, sibling to custom-skills + custom-handbooks (AgDR-0022)
- Topology composition (e.g. "NextJS web + Python ML service") — pick the closest single shape, manually instantiate the second
- Per-team topology overrides — file a follow-up if multi-team adopters need this
- Auto-detection of which topology the adopter should pick — `/handover` already detects the tech stack in step 3; future PR can wire that into the topology suggestion
