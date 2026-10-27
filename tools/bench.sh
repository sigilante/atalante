#!/bin/zsh
#  tools/bench.sh:  the P7 benchmark.  +/⍳N through the GENERIC interpreter
#  (every element a scalar extension and a one-element ray) and through the
#  EMITTED formula with the specialised g-reduce (Lagoon's sum over the
#  packed ray), each as one jockc run under NockVM; the compile is the same
#  for both, so the difference between runs is the evaluation.
#
#    bench.sh N generic|emitted [STMT]   prints the wall time of the run (STMT over v ← ⍳N, default +/v)
#    bench.sh N baseline                 the same run with no statement: the compile and the setup
#  Subtract the baseline at the same N to get the statement's own cost.
#  Env:  JOCK as tools/atlc.sh
set -e
ROOT="${0:A:h:h}"
JOCK=${JOCK:-$HOME/Code/jock}
N="$1"; MODE="$2"; STMT="${3:-+/v}"
B=$(mktemp -d); trap "/bin/rm -rf $B" EXIT
python3 "$ROOT/tools/atlc.py" gen >/dev/null
EM=false; [[ "$MODE" == emitted ]] && EM=true; [[ "$MODE" == baseline ]] && STMT=""
python3 - "$N" "$EM" "$STMT" "$B/bench.jock" <<'PY'
import sys
n, em, stmt, out = sys.argv[1:5]
esc = stmt.replace("\\", "\\\\").replace('"', '\\"').replace("{", "{{").replace("}", "}}")
open(out, "w", encoding="utf-8").write('import atl;\natl.bench(%s, %s, "%s")\n' % (n, em, esc))
PY
s=$(date +%s)
out=$(PYTHONINTMAXSTRDIGITS=0 zsh "$JOCK/tools/jockc.sh" --diag --data-dir "$ROOT/src" --data-dir "$ROOT/pkgs" run "$B/bench.jock" 2>&1 | tail -1)
e=$(date +%s)
val=$(printf '%s' "$out" | python3 -c '
import sys, json
sys.set_int_max_str_digits(0)
r = json.loads(sys.stdin.read()); v = r.get("value")
print(v.to_bytes((v.bit_length()+7)//8, "little").decode() if isinstance(v, int) else r.get("status"))')
echo "bench N=$N $MODE $STMT: $((e - s)) s  ->  $(printf %s "$val" | head -c 60)"
