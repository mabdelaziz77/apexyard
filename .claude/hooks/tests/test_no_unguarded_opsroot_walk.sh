#!/bin/bash
# Regression guard for apexyard#12.
#
# The bug: ticket-creating skills resolved the ops fork root with an inline
# upward walk that stripped path segments with `${r%/*}` but had NO empty-string
# guard:
#
#   ops_root="$(r=$PWD;while [ ! -f "$r/onboarding.yaml" ] && [ "$r" != / ];do r=${r%/*};done;echo $r)"
#
# On a split-portfolio fork, onboarding.yaml is NOT at the fork root (it lives
# in the private sibling repo). The walk never finds it and descends to `/`;
# `${r%/*}` then turns `/` into the empty string, the `[ "$r" != / ]` guard
# never matches "", and the loop spins forever at ~100% CPU.
#
# The fix: source `_lib-ops-root.sh` and call `resolve_ops_root`, which is
# .apexyard-fork-aware, session-pin-aware, and always terminates.
#
# This test fails if any skill or hook contains a `${r%/*}` strip-walk WITHOUT
# an accompanying `[ -n "$r" ]` empty-string guard on the same line. The
# canonical settings-wrapper pattern uses `${r%/*}` *with* the `-n` guard and
# is therefore correctly exempt — the guard is the difference between a walk
# that terminates and one that hangs.
#
# Assumption: the strip and its guard live on the same logical line (true for
# every real use today — the settings wrapper and the old skill snippets are
# both one-liners). A future multi-line walk would need this test extended.
#
# To run:  ./.claude/hooks/tests/test_no_unguarded_opsroot_walk.sh
# Exit 0 = clean, 1 = a dangerous (unguarded) strip-walk was found.

set -u

ROOT=$(cd "$(dirname "$0")/../../.." && pwd)
SELF=$(basename "$0")

FAIL=0
HITS=""

while IFS= read -r line; do
  [ -z "$line" ] && continue
  # line is "file:lineno:content". Exempt this test file's own examples.
  case "$line" in *"$SELF"*) continue ;; esac
  # Safe iff the same line also carries the `[ -n "$r" ]` empty-string guard.
  if ! printf '%s' "$line" | grep -q -- '-n "\$'; then
    HITS="${HITS}${line}
"
  fi
done <<EOF
$(grep -rn --include='*.md' --include='*.sh' 'r=${r%/\*}' "$ROOT/.claude/skills" "$ROOT/.claude/hooks" 2>/dev/null || true)
EOF

if [ -n "$HITS" ]; then
  echo "FAIL: unguarded \${r%/*} ops-root strip-walk found (apexyard#12)." >&2
  echo "      Use resolve_ops_root from _lib-ops-root.sh, or pair the walk with a [ -n \"\$r\" ] guard:" >&2
  printf '%s' "$HITS" | sed 's/^/  /' >&2
  FAIL=1
fi

if [ "$FAIL" = 0 ]; then
  echo "PASS: no unguarded \${r%/*} ops-root walks in skills or hooks"
fi
exit "$FAIL"
