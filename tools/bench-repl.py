#!/usr/bin/env python3
"""bench-repl.py: time statements at the RUNNING kernel's prompt under jojo
in tmux (tools/atl-repl.sh start), the P11 benchmark lane.  tools/bench.sh
measures the jetless honk-kick runtime; this measures the runtime a user
has, jets and all, by typing `v ← ⍳N` and then each statement, and timing
the wait for the next prompt.

  tools/bench-repl.py [--path BOTH|INTERP|EMIT] N [STMT ...]
      (default statements: +/v  +/1.5×v  x←1.5×v  1.5×v)
  --path types `)PATH X` first, so every line runs through that path alone
  (the session's default, BOTH, runs the interpreter and the emitter and
  compares them).  Env:  SESSION (default atlv)
"""
import importlib.util, os, sys, time
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
spec = importlib.util.spec_from_file_location("repl_test", os.path.join(ROOT, "tools", "repl-test.py"))
rt = importlib.util.module_from_spec(spec); spec.loader.exec_module(rt)


def main():
    args = sys.argv[1:]
    path = None
    if args[:1] == ["--path"]:
        path, args = args[1], args[2:]
    if not args:
        sys.exit(__doc__)
    n = args[0]
    stmts = args[1:] or ["+/v", "+/1.5×v", "x←1.5×v", "1.5×v"]
    if not rt.wait_prompt(600):
        sys.exit("bench-repl: no prompt")
    if path is not None:
        print(f"bench-repl  )PATH {path}: {rt.send(')PATH ' + path)}")
    t = time.time()
    if rt.send(f"v ← ⍳{n}", timeout=600) is None:
        sys.exit("bench-repl: v ← ⍳N did not return in 600 s")
    tag = f" [{path}]" if path else ""
    print(f"bench-repl N={n}{tag}  v ← ⍳{n}: {time.time() - t:6.2f} s")
    for s in stmts:
        t = time.time()
        got = rt.send(s, timeout=600)
        dt = time.time() - t
        head = "(no prompt in 600 s)" if got is None else (got.split("\n")[0][:60] if got else "(no output)")
        print(f"bench-repl N={n}{tag}  {s}: {dt:6.2f} s  ->  {head}")


if __name__ == "__main__":
    main()
