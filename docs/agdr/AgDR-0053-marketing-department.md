# Add a Marketing Department (4 Roles + 3 GTM Skills)

> In the context of an SDLC framework that ships 19 roles across 5 departments but has no
> marketing/growth capability, facing operator commercial projects (JR Prism, JR Image Optimizer)
> that need go-to-market, launch, content/SEO, and lifecycle execution, I decided to add a
> first-class **Marketing department** of 4 roles plus 3 go-to-market skills, to achieve
> campaign/content/launch execution as a native part of the SDLC, accepting that this grows the
> role/agent surface (19→23 roles, 23→27 agents) and imposes four new persona names on adopters.

## Context

ApexYard models a company as departments of activatable roles (Engineering, Product, Design,
Security, Data). Every phase of the SDLC has an owning role, and `role-triggers.md` +
`detect-role-trigger.sh` decide which role activates and whether it runs in-thread or as a spawned
sub-agent (AgDR-0050 § Axis 6).

There is no marketing function anywhere in the framework. Nobody owns:

- Go-to-market & launch planning
- Acquisition funnels, paid channels, conversion
- Content, copy, SEO/GEO, social, docs-as-marketing, app-directory listings
- Lifecycle: onboarding emails, newsletters, retention, win-back

The adjacent existing pieces are **analysis sensors**, not execution roles: `/seo-audit`,
`/geo-audit` (discoverability audits), `/stakeholder-update` (reporting), and the Product Analyst
(market/competitive research). They tell you the state of the world; none of them own *doing the
marketing*.

This gap is concrete for the operator's portfolio: **JR Prism** and **JR Image Optimizer** are
freemium Joomla extensions sold on the Joomla Extensions Directory (JED) + an own storefront, with
a newsletter-driven growth motion. They need listing optimization, launch sequencing, content, and
lifecycle email — exactly the missing department.

Adding a department is a structural change to the framework's core model, hence this AgDR.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| **A. Full 4-role Marketing dept + 3 GTM skills (chosen)** | Complete coverage (strategy + acquisition + content/SEO + lifecycle); mirrors the Head+specialists shape of the other departments; reusable across the whole portfolio | Largest surface: 4 roles + 4 agents + 3 skills + wiring + tests + 4 new persona names |
| B. Single Growth Marketer + Head only (2 roles) | Smaller; still gives a marketing owner | Content/SEO + lifecycle folded into one overloaded role; weaker fit for content-heavy + newsletter-driven products |
| C. No role — reuse existing skills | Zero new surface | Leaves the execution gap exactly as-is; `/seo-audit` et al. stay analysis-only; no persona to activate for launch/campaign work |
| D. Outsource marketing (out of framework) | No framework change | Defeats the point — the framework is meant to model the whole company; marketing would be the only unmodelled function |

## Decision

Chosen: **Option A — a full Marketing department of 4 roles plus 3 go-to-market skills.**

Composition:

| Role | Persona | Class (AgDR-0050 § Axis 6) | Rationale for class |
|------|---------|----------------------------|---------------------|
| Head of Marketing | **Rashid** | isolated-work-class | Strategy/positioning; sparse, benefits from isolated context — same shape as the other Heads |
| Growth Marketer | **Layla** | in-flow-class | Builds funnels/landing copy/launch plans iteratively alongside the main thread |
| Content & SEO Marketer | **Samir** | in-flow-class | Authors content/copy; conversational, loses value if context is split out |
| Lifecycle Marketer | **Dalia** | in-flow-class | Authors email/newsletter/retention flows iteratively |

New skills (modelled on existing SKILL.md shape):

- `/gtm-plan` — go-to-market & launch plan (Head of Marketing / Growth Marketer)
- `/campaign-brief` — single-channel campaign brief (Growth Marketer)
- `/listing-audit` — app-directory / JED listing optimization (Content & SEO Marketer)

The roles also reuse the existing `/seo-audit`, `/geo-audit`, `/stakeholder-update`, and `/roadmap`
skills rather than duplicating them.

Persona names are new, gender-mixed, and collision-checked against the existing 24 (AgDR-0018).
Class assignment follows the precedent set by Product (Head-of-Product isolated, Product Manager
in-flow): the strategic Head is isolated; the executing specialists are in-flow.

**Placement**: this is framework work that ships to every adopter, so it lands on the public fork
(`mabdelaziz77/apexyard`) and ultimately upstream — not in any private portfolio repo.

## Consequences

- **Role count 19 → 23; agent count 23 → 27.** `CLAUDE.md` Departments table, the agent-layer count
  + breakdown, and `role-triggers.md`'s "19 role definitions" references are updated. Skill count +3.
- **`detect-role-trigger.sh` gains prompted-activation aliases** for the four roles (head of
  marketing, growth marketer, content/seo marketer, lifecycle/email marketer). No new path- or
  label-based triggers — there is no canonical "marketing path" in a repo, so auto-firing on diffs
  would be noise. Marketing roles activate via prompt or via the auto-activation signals documented
  in `role-triggers.md` (launch/GTM, landing/ad copy, content/SEO/listing, email/newsletter).
- **The role-trigger test suite** gains marketing cases, so the new wiring is regression-guarded.
- **No behavioural change to existing roles** — purely additive. Existing triggers, agents, and
  skills are untouched except for the shared `ROLES_TABLE` and counts.
- **Adopters inherit four new persona names.** As with AgDR-0018, names are overridable per-fork by
  editing the `persona_name` field / `**Persona name**:` line; no hook or skill matches on them.
- **Future option**: marketing-specific path/label triggers (e.g. a `marketing` issue label →
  Growth Marketer) can be added later without changing this design — the plumbing already supports
  label-based triggers.

## Artifacts

- Issue: [mabdelaziz77/apexyard#9](https://github.com/mabdelaziz77/apexyard/issues/9)
- PR: (to be added on creation)
- Files added: `roles/marketing/{head-of-marketing,growth-marketer,content-marketer,lifecycle-marketer}.md`,
  `.claude/agents/{head-of-marketing,growth-marketer,content-marketer,lifecycle-marketer}.md`,
  `.claude/skills/{gtm-plan,campaign-brief,listing-audit}/SKILL.md`
- Files changed: `.claude/rules/role-triggers.md`, `.claude/hooks/detect-role-trigger.sh`,
  `.claude/hooks/tests/test_detect_role_trigger.sh`, `CLAUDE.md`
- Related: AgDR-0018 (persona naming), AgDR-0050 (agent architecture / activation classes)
