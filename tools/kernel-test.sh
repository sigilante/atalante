#!/bin/zsh
#  tools/kernel-test.sh:  the kernel VECTOR (plan P6 exit test).  Builds
#  app/kernel.jock with +kernel:jock exactly as kern.sh does, then drives
#  it the way the runtime does (+kslam, runtime.md R-90): pokes the
#  README's sieve through arm 23 as [%command line] events, collects the
#  effects, and PEEKS the store through arm 22.  tools/kernel-test.py
#  decodes the product and checks both the printed lines and the peeked
#  array.
#
#  Env:  JOCK (default ~/Code/jock), HONK, KICK as Jock's tools
set -e
ROOT="${0:A:h:h}"
JOCK=${JOCK:-$HOME/Code/jock}
HONK=${HONK:-$HOME/.cargo/bin/honk-codex}
KICK=${KICK:-$HOME/.cargo/bin/honk-kick}
B=$(mktemp -d); trap "/bin/rm -rf $B" EXIT
python3 "$ROOT/tools/atlc.py" gen >/dev/null   # packages, when stale
LSRC=$(python3 "$JOCK/tools/libs.py" --root "$ROOT/app/kernel.jock" "$ROOT/src" "$ROOT/pkgs" "$JOCK/crates/jockc/hoon/lib")
rsync -a "$JOCK/crates/jockc/hoon/" "$B/tree/"
print -r -- "$LSRC" > "$B/lsrc.txt"
python3 - "$ROOT/app/kernel.jock" "$B/tree/kt.hoon" "$B/lsrc.txt" "$JOCK/tools" "$ROOT/tests/kernel/sieve.txt" <<'PY'
import sys
sys.path.insert(0, sys.argv[4])
from libs import cordhex
lsrc = open(sys.argv[3]).read().strip()
src = open(sys.argv[1]).read()
lines = [l for l in open(sys.argv[5], encoding="utf-8").read().split("\n") if l.strip()]
rows = "\n".join("      `@t`%s" % cordhex(l) for l in lines)
open(sys.argv[2], 'w').write(
  "/-  jock, typ\n/+  jf=jock\n"
  + "=/  ls=(map term lsrc:typ)  " + lsrc + "\n"
  + "=/  jck  ~(. jf [ls %.n ~ ~])\n"
  + "=/  k  (kernel:jck `@t`" + cordhex(src) + ")\n"
  + "=/  lines=(list @t)\n  :~\n" + rows + "\n  ==\n"
  + "=/  fx=(list *)  ~\n"
  + "|-  ^-  *\n"
  + "?~  lines  [(flop fx) (kslam:jck k 22 0)]\n"
  + "=/  q  (kslam:jck k 23 [%command i.lines])\n"
  + "?>  ?=(^ q)\n"
  + "$(k +.q, lines t.lines, fx [-.q fx])\n")
PY
"$HONK" --new --arbitrary --output "$B/kt.jam" --prelude "$JOCK/vendor/hoon-138.hoon" "$B/tree/kt.hoon" "$B/tree" > "$B/honk.log" 2>&1 || {
  echo "kernel-test: compile failed; honk log tail:" >&2; grep -v INFO "$B/honk.log" | tail -20 >&2; exit 2; }
"$KICK" "$B/kt.jam" "$B/out.jam" > "$B/kick.log" 2>&1 || { echo "kernel-test: kick crashed" >&2; tail -5 "$B/kick.log" >&2; exit 2; }
python3 "$ROOT/tools/kernel-test.py" "$B/out.jam" "$ROOT/tests/kernel/sieve.txt" "$ROOT/tests/kernel/sieve.expect"
