---
name: listing-audit
description: Audit + optimize an app-directory / marketplace listing (e.g. Joomla Extensions Directory) — title, description, keywords, screenshots, ratings, conversion. Owned by the Content & SEO Marketer.
disable-model-invocation: false
argument-hint: "[project-name | listing-url]"
effort: medium
---

# /listing-audit — App-Directory / Marketplace Listing Optimization

Audit a product's listing on an app directory or marketplace (Joomla Extensions Directory, plugin repos, app stores) and produce a prioritised set of fixes to improve discovery and conversion. The directory is often the highest-intent acquisition channel for an extension/plugin — this is where browsers become installs.

## Activated role

Activate the **[Content & SEO Marketer](../../../roles/marketing/content-marketer.md)** (Samir). Print the activation marker per `.claude/rules/role-triggers.md` § "How to signal activation".

## Path resolution

Resolve paths via `.claude/hooks/_lib-portfolio-paths.sh`:

```bash
source "$(git rev-parse --show-toplevel)/.claude/hooks/_lib-read-config.sh"
source "$(git rev-parse --show-toplevel)/.claude/hooks/_lib-portfolio-paths.sh"
projects_dir=$(portfolio_projects_dir)
```

Output path: `<projects_dir>/<project>/marketing/listing-audit-<slug>.md`.

## Usage

```
/listing-audit jr-prism
/listing-audit https://extensions.joomla.org/extension/...
```

## Process

### 1. Resolve the listing + the product truth

- Pull the product's README / PRD / feature inventory from the registry so claims in the listing match reality.
- If a listing URL is given, read it (WebFetch). Otherwise work from the draft listing copy.

### 2. Audit against the listing dimensions

| Dimension | Check |
|-----------|-------|
| **Title** | Carries the primary keyword + the category; scannable |
| **Short description / tagline** | One benefit-led line; the value prop, not a feature list |
| **Long description** | Benefit-before-feature; structured; proof (screenshots, numbers) |
| **Keywords / tags** | Match real search intent in the directory; no stuffing |
| **Screenshots / media** | Show the product doing its job; captioned; current |
| **Category + metadata** | Correct category; version/compat fields accurate |
| **Social proof** | Ratings, reviews, install count surfaced; review-ask in place |
| **Pricing / freemium framing** | Free tier obvious; upgrade path clear |
| **CTA + links** | Clear next step; docs + support links present and live |

### 3. Write the audit

```markdown
# {Product} — Listing Audit ({directory})

**Date**: YYYY-MM-DD · **Owner**: Content & SEO Marketer · **Listing**: {url}

## Verdict   (PASS / IMPROVE / REWRITE)
## Findings by dimension
| Dimension | State | Fix | Priority |
## Rewritten copy   (title + tagline + long description, ready to paste)
## Quick wins   (do today)
## Next actions
```

### 4. Confirm + hand off

Print the output path. Surface technical SEO of the public product page to `/seo-audit`, and feed listing performance back into the parent `/gtm-plan`.

## Rules

1. **Claims must match the product.** Verify every listing claim against the repo / PRD.
2. **Benefit before feature** in every rewrite.
3. **Ship paste-ready copy**, not just critique — the rewritten title + tagline + description.
4. **Prioritise** — mark quick wins vs structural rewrites so the operator can act today.

## Related

- `/seo-audit`, `/geo-audit` — discoverability of the public product page
- `/gtm-plan`, `/campaign-brief` — where the listing sits in the funnel

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
