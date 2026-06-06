# {Extension Name} — JED Submission Metadata

Pre-filled values for the [Joomla Extensions Directory](https://extensions.joomla.org) listing
form. Copy this to `docs/jed-submission.md` in your extension repo and replace every
**`{placeholder}`**. Update it each release so the listing and the package stay in sync.

> Before submitting: build the package (`bash build/build.sh`), run the **JEDChecker** component
> against it on a Joomla test site, and smoke-test on a clean Joomla install. See the checklist
> at the bottom.

## Core listing fields

| JED field | Value |
|-----------|-------|
| Extension title | {Human product name, e.g. "Acme Slider"} |
| Filename / "install as" (must match the manifest `<name>`) | `{mod_/com_/plg_ install name}` |
| Extension type | {Module — Site / Component / Plugin — Group} |
| Current version | {x.y.z — matches the manifest `<version>`} |
| Joomla compatibility | {e.g. 5.x, 6.x} |
| Minimum PHP | {e.g. 8.2} |
| License | GNU General Public License v2 or later (GPL-2.0-or-later) |
| Price model | {Free / Free + paid Pro / Paid} |
| Primary category | {JED category, e.g. "Content & News → Content Display"} |
| Developer / author | {Vendor} |
| Author URL | {https://…} |
| Author email | {email} |

## URLs

| JED field | Value |
|-----------|-------|
| Homepage / product page | {URL} |
| Download URL | {store download or GitHub release URL} |
| Demo URL | {live demo, optional but boosts conversions} |
| Documentation URL | {docs URL} |
| Support URL | {support form / forum / email page} |

## Descriptions

**Short description** (one line, shown in listings):

> {One-sentence value proposition.}

**Long description** (listing body):

> {2–4 paragraphs: what it does, who it's for, the headline features, and why it's worth installing.}

**Key features** (bullets):

- {feature}
- {feature}
- {feature}

## Screenshots to attach

- [ ] {Admin configuration screen}
- [ ] {Primary front-end view}
- [ ] {A second representative view}
- [ ] {Logo / icon — square, for the listing header}

## Keywords / tags

`{comma-separated keywords buyers would search}`

## Pre-submission checklist

- [ ] `bash build/build.sh` produces `dist/<ext>-<version>.zip`
- [ ] Installs cleanly on a fresh, supported Joomla version
- [ ] **JEDChecker** component run against the package → no errors
- [ ] Smoke test: exercise the extension's primary flows
- [ ] Manifest `<version>` matches the package filename and this doc
- [ ] All file headers carry the GPL notice; `LICENSE.txt` present
- [ ] Listing name + install name match the manifest
