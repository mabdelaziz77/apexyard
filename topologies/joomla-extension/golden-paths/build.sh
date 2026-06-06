#!/usr/bin/env bash
#
# Build an installable Joomla extension package.
#
# Copy this to build/build.sh in your extension repo. It is manifest-agnostic:
# it auto-detects the extension manifest (the *.xml with an <extension> root),
# reads the extension name + <version>, and produces a clean
# dist/<ext>-<version>.zip — the file you feed to the JEDChecker component and
# upload through Joomla's "Extensions -> Install". Never needs editing on a
# version bump.
#
# Usage:  bash build/build.sh
#
# Part of the apexyard joomla-extension topology.

set -euo pipefail

command -v zip >/dev/null 2>&1 || {
  echo "ERROR: 'zip' is not installed. Install it (brew install zip | apt-get install zip) and retry." >&2
  exit 1
}

# Repo root = parent of this script's directory.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Locate the extension manifest (the XML with an <extension> root element).
# Assumes ONE extension manifest per repo (the common case for a single
# component/module/plugin). For a multi-extension package, adapt this line.
MANIFEST="$(find . -maxdepth 2 -name '*.xml' -exec grep -l '<extension' {} \; | head -1)"
[ -n "$MANIFEST" ] || { echo "ERROR: no extension manifest (*.xml with <extension>) found." >&2; exit 1; }

EXT="$(basename "$MANIFEST" .xml)"
VERSION="$(sed -n 's:.*<version>\(.*\)</version>.*:\1:p' "$MANIFEST" | head -1)"
[ -n "$VERSION" ] || { echo "ERROR: could not read <version> from $MANIFEST." >&2; exit 1; }

OUT="dist/${EXT}-${VERSION}.zip"
mkdir -p dist
rm -f "$OUT"

# Zip the whole tree minus dev-only files. Joomla installs only what the
# manifest declares; extra root files (LICENSE.txt, README.md) are harmless.
# Dev tooling, docs, editor state, and VCS metadata are excluded.
zip -r -q "$OUT" . \
  -x './.git/*' \
  -x './.github/*' \
  -x './.claude/*' \
  -x './.idea/*' \
  -x './.vscode/*' \
  -x './docs/*' \
  -x './build/*' \
  -x './dist/*' \
  -x './tests/*' \
  -x './node_modules/*' \
  -x './vendor/*' \
  -x 'CLAUDE.md' \
  -x '.gitignore' \
  -x '*.zip' \
  -x '*.DS_Store'

echo "Built $OUT ($(du -h "$OUT" | cut -f1))"
