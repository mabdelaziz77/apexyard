---
name: gtm-plan
description: Author a go-to-market & launch plan — segment, positioning, channel mix, funnel targets, and a pre/launch/post calendar. Owned by the Head of Marketing / Growth Marketer.
disable-model-invocation: false
argument-hint: "[project-name | feature]"
effort: medium
---

# /gtm-plan — Go-to-Market & Launch Plan

Author a concrete go-to-market plan for a product or a launch: who it's for, how it's positioned, which channels carry it, the funnel targets, and the launch calendar. Produces a single markdown plan the Growth Marketer can execute against.

## Activated role

Activate the **[Head of Marketing](../../../roles/marketing/head-of-marketing.md)** (Rashid) for the strategy/positioning/channel decisions, with handoff to the **[Growth Marketer](../../../roles/marketing/growth-marketer.md)** (Layla) for the executable funnel + calendar. Print the activation marker per `.claude/rules/role-triggers.md` § "How to signal activation".

## Path resolution

Resolve the registry + per-project docs dir via `.claude/hooks/_lib-portfolio-paths.sh`. Source the helper at the top of any bash block that touches those paths:

```bash
source "$(git rev-parse --show-toplevel)/.claude/hooks/_lib-read-config.sh"
source "$(git rev-parse --show-toplevel)/.claude/hooks/_lib-portfolio-paths.sh"
projects_dir=$(portfolio_projects_dir)
```

Output path: `<projects_dir>/<project>/marketing/gtm-<slug>.md`. Don't hardcode literal `projects/` — the helper resolves single-fork vs split-portfolio mode.

## Usage

```
/gtm-plan jr-prism                 # GTM plan for a registered project
/gtm-plan jr-image-optimizer v2    # GTM plan for a specific launch
/gtm-plan "new freemium tier"      # free-form launch
```

## Process

### 1. Resolve the input + pull context

- **Project name** — read the registry + the project's README / PRD / roadmap if present.
- **Free-form** — slugify the title; output under `<projects_dir>/_inbox/marketing/`.

Print 3–5 lines of starting context so the user can correct your read before you build the plan.

### 2. Work through the GTM framework — ONE section at a time

Don't batch. Confirm each before moving on.

1. **Segment** — the narrowest high-value audience for *this* launch, and why now.
2. **Positioning** — the one-line value proposition vs the current alternative (reuse `/validate-idea`'s Q2 answer if one exists).
3. **Channel mix** — where that segment already is. Pick ONE primary channel; list secondaries. For a bootstrapped product, prefer owned/organic (content, SEO, directory listing, email) before paid.
4. **Funnel targets** — acquisition → activation → conversion → retention, with a number or a target per stage.
5. **Launch calendar** — pre-launch, launch, post-launch, each with owner + date + asset.

### 3. Write the plan

```markdown
# {Project / Launch} — Go-to-Market Plan

**Date**: YYYY-MM-DD · **Owner**: {Head of Marketing} · **Status**: draft

## Segment
## Positioning
## Channel mix (primary + secondary)
## Funnel targets
| Stage | Target | Channel | Metric |
## Launch calendar
| Phase | Date | Owner | Assets |
## Risks / dependencies
## Next actions  (hand to Growth Marketer → /campaign-brief per channel)
```

### 4. Confirm + hand off

Print the output path. Offer the natural next step: `/campaign-brief` for the primary channel, and `/listing-audit` if the channel is an app directory.

## Rules

1. **One primary channel.** A plan that spreads a small budget across many channels is a non-plan.
2. **Every funnel stage has a number** or an explicit "TBD — measure first".
3. **Calendar items have owners.** No ownerless launch steps.
4. **Reuse, don't re-derive.** Pull positioning from an existing `/validate-idea` or PRD when present.
5. **Output is one page** where possible — executable, not a manifesto.

## Related

- `/campaign-brief` — per-channel execution brief (Growth Marketer)
- `/listing-audit` — app-directory / JED listing optimization (Content & SEO Marketer)
- `/seo-audit`, `/geo-audit` — organic discoverability audits
- `/roadmap`, `/stakeholder-update` — sequencing + reporting

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
