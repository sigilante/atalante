#!/bin/zsh
#  tools/pkg.sh:  build the Lagoon package jam (pkg/lagoon-core.hoon
#  over vendor/numerics) the way Jock's tools/pkg.sh builds the chain
#  package:  the Jock compiler tree is the build tree, the vendored
#  numerics sur/ and lib/ are laid beside it, honk compiles the core
#  against the hoon-138 prelude, and the artifact is honk's TRAP (the
#  construction formula), which the consuming program evaluates at
#  startup.  The kick is load-bearing:  it proves the formula runs
#  and yields a well-formed $hlib before anything ships.
#
#  Usage:  pkg.sh [out.jam]        (default pkgs/lagoon.jam)
#  Env:    JOCK (default ~/Code/jock), HONK, KICK (as Jock's tools)
#  Writes <out>.sha beside the jam:  the sha256 of the inputs, which
#  tools/atlc.py compares to decide whether to rebuild.
set -e
ROOT="${0:A:h:h}"
JOCK=${JOCK:-$HOME/Code/jock}
HONK=${HONK:-$HOME/.cargo/bin/honk-codex}
KICK=${KICK:-$HOME/.cargo/bin/honk-kick}
OUT=${1:-$ROOT/pkgs/lagoon.jam}
B=$(mktemp -d); trap "/bin/rm -rf $B" EXIT
rsync -a "$JOCK/crates/jockc/hoon/" "$B/tree/"
rsync -a "$ROOT/vendor/numerics/" "$B/tree/"
/bin/cp "$ROOT/pkg/lagoon-core.hoon" "$B/tree/pkgcore.hoon"
"$HONK" --new --arbitrary --output "$B/p.jam" \
  --prelude "$JOCK/vendor/hoon-138.hoon" \
  "$B/tree/pkgcore.hoon" "$B/tree" > "$B/honk.log" 2>&1 || {
  echo "pkg: compile failed; honk log tail:" >&2
  grep -v INFO "$B/honk.log" | tail -20 >&2; exit 2; }
"$KICK" "$B/p.jam" "$B/value.jam" || { echo "pkg: package evaluation crashed" >&2; exit 2; }
mkdir -p "$(dirname "$OUT")"
/bin/cp "$B/p.jam" "$OUT"
cat "$ROOT/pkg/lagoon-core.hoon" "$ROOT"/vendor/numerics/*/*.hoon | shasum -a 256 | cut -d' ' -f1 > "$OUT.sha"
echo "package: $OUT ($(wc -c < "$OUT" | tr -d ' ') bytes, sha256 $(shasum -a 256 "$OUT" | cut -d' ' -f1))"
