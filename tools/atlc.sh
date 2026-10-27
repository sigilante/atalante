#!/bin/zsh
#  tools/atlc.sh:  the Atalante front door.
#
#    atlc.sh corpus [CASE.atl ...]   run the corpus (tests/atl), print the table
#    atlc.sh run CASE.atl            run one case, print the transcript
#    atlc.sh gen [CASE.atl ...]      write tests/gen/corpus.jock only
#    atlc.sh lex [CASE.atl ...]      run the lex corpus (tests/lex), print the table
#    atlc.sh lexcheck                lex every eval-corpus input line; list refusals
#    atlc.sh parse [CASE.atl ...]    run the parse corpus (tests/parse), print the table
#    atlc.sh check                   typecheck src/ (a program that imports atl)
#    atlc.sh pkg                     rebuild the packages from pkg/ and vendor/
#    atlc.sh oracle                  check the emission goldens against the Python Nockasm expander
#    atlc.sh kernel [--sealed]       build the REPL kernel jam, out/atl-kernel.jam (app/kernel.jock)
#    atlc.sh kernel-test             the kernel vector: poke the sieve through arm 23, peek the store through arm 22
#    atlc.sh repl-test [CASE.atl]    type a case into the running kernel (tools/atl-repl.sh start) and check every line
#    atlc.sh bench N generic|emitted [STMT]  the P7 benchmark: STMT over v ← ⍳N through one path
#
#  Env:  JOCK  the Jock checkout (default ~/Code/jock); its tools/jockc.sh
#        is the compiler (honk-codex + honk-kick under NockVM, the
#        authority lane).  jonk is pended (docs/plan.md P0, S-3).
set -e
ROOT="${0:A:h:h}"
JOCK=${JOCK:-$HOME/Code/jock}
case "$1" in
  corpus|run|gen|lex|lexcheck|parse)  exec python3 "$ROOT/tools/atlc.py" "$@" ;;
  check)
    T=$(mktemp -d); trap "/bin/rm -rf $T" EXIT
    print 'import atl;\natl.session(["1"])' > "$T/check.jock"
    exec zsh "$JOCK/tools/jockc.sh" --data-dir "$ROOT/src" --data-dir "$ROOT/pkgs" check "$T/check.jock" ;;
  pkg)  exec zsh "$ROOT/tools/pkg.sh" ;;
  oracle)  exec python3 "$ROOT/tools/goldens-oracle.py" ;;
  kernel-test)  exec zsh "$ROOT/tools/kernel-test.sh" ;;
  repl-test)  shift; exec python3 "$ROOT/tools/repl-test.py" "$@" ;;
  bench)  shift; exec zsh "$ROOT/tools/bench.sh" "$@" ;;
  kernel)
    shift
    python3 "$ROOT/tools/atlc.py" gen >/dev/null   # builds the packages when stale
    exec zsh "$JOCK/tools/kern.sh" "$@" --data-dir "$ROOT/src" --data-dir "$ROOT/pkgs" --data-dir "$JOCK/crates/jockc/hoon/lib" "$ROOT/app/kernel.jock" "$ROOT/out/atl-kernel.jam" ;;
  *)  sed -n '2,12p' "$0" | sed 's/^#  \{0,1\}//'; exit 2 ;;
esac
