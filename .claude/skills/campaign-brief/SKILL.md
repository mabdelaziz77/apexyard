---
name: campaign-brief
description: Author a single-channel campaign brief — objective, audience, message, assets, budget, and success metric. Owned by the Growth Marketer.
disable-model-invocation: false
argument-hint: "[channel | campaign-name]"
effort: low
---

# /campaign-brief — Single-Channel Campaign Brief

Turn a go-to-market plan's channel line into an executable brief: one channel, one objective, one audience, a clear message, the assets needed, the budget, and the metric that says it worked. Keeps campaigns tight and measurable.

## Activated role

Activate the **[Growth Marketer](../../../roles/marketing/growth-marketer.md)** (Layla), with a content handoff to the **[Content & SEO Marketer](../../../roles/marketing/content-marketer.md)** (Samir) for copy/assets. Print the activation marker per `.claude/rules/role-triggers.md` § "How to signal activation".

## Path resolution

Resolve paths via `.claude/hooks/_lib-portfolio-paths.sh`:

```bash
source "$(git rev-parse --show-toplevel)/.claude/hooks/_lib-read-config.sh"
source "$(git rev-parse --show-toplevel)/.claude/hooks/_lib-portfolio-paths.sh"
projects_dir=$(portfolio_projects_dir)
```

Output path: `<projects_dir>/<project>/marketing/campaign-<channel>-<slug>.md`.

## Usage

```
/campaign-brief jed-listing-launch
/campaign-brief "reddit r/joomla"
/campaign-brief newsletter-q3
```

## Process

### 1. Anchor to a GTM plan if one exists

Look for `<projects_dir>/<project>/marketing/gtm-*.md`. If found, pull the segment + positioning + the channel's funnel target so the brief stays consistent. If not, note that this brief is standalone.

### 2. Fill the brief — ONE field at a time

1. **Objective** — the single outcome (signups, installs, trials, replies). One metric.
2. **Audience** — who exactly, on this channel.
3. **Message** — the core hook + the proof. The one thing they should remember.
4. **Assets** — what must be created (copy, image, landing page, listing). Flag handoffs to Content.
5. **Budget + timing** — spend cap, run dates.
6. **Success metric + kill line** — what "worked" is, and at what point you stop.

### 3. Write the brief

```markdown
# Campaign Brief — {Channel}: {Name}

**Date**: YYYY-MM-DD · **Owner**: Growth Marketer · **GTM**: {link or "standalone"}

## Objective (one metric)
## Audience
## Message (hook + proof)
## Assets needed   (→ Content & SEO Marketer for copy)
## Budget + dates
## Success metric + kill line
## Tracking   (→ Data Analyst: what to instrument)
```

### 4. Confirm + hand off

Print the output path. Hand asset creation to the Content & SEO Marketer and tracking to the Data Analyst.

## Rules

1. **One channel per brief.** Multi-channel = multiple briefs anchored to one `/gtm-plan`.
2. **One objective, one metric.** If you can't name the metric, the campaign isn't ready.
3. **Declare the kill line** before launch so a losing campaign gets stopped, not rationalised.
4. **Assets list names owners** — copy/design handoffs are explicit.

## Related

- `/gtm-plan` — the parent go-to-market plan
- `/listing-audit` — if the channel is an app directory
- `/seo-audit`, `/geo-audit` — organic-channel readiness

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
