#!/usr/bin/env python3
"""repl-test.py: type a corpus case into the RUNNING kernel under jojo in
tmux (tools/atl-repl.sh) and hold every printed line to the case's
expectations --- the P6 exit test: the README transcript, typed at the
prompt, reproduces every printed line.

  tools/repl-test.py [CASE.atl]     (default tests/atl/readme-red.atl)
"""
import os, sys, time, subprocess
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
from atlc import parse_case
SESSION = os.environ.get("SESSION", "atl")


def pane():
    """the pane, minus the runtime's log lines (and their wrapped tails)"""
    raw = subprocess.run(["tmux", "capture-pane", "-p", "-S", "-500", "-t", SESSION],
                         capture_output=True, text=True).stdout.rstrip("\n").split("\n")
    out, skipping = [], False
    for l in raw:
        if " INFO " in l or " WARN " in l or " ERROR " in l:
            skipping = True; continue
        if skipping and l.startswith(" "):
            continue
        skipping = False
        out.append(l)
    return out


def wait_prompt(timeout):
    t = time.time()
    while time.time() - t < timeout:
        lines = [l for l in pane() if l != ""]
        if lines and lines[-1] == "jojo>":
            return True
        time.sleep(0.3)
    return False


def send(line, timeout=120):
    before = len([l for l in pane() if l != ""])
    subprocess.run(["tmux", "send-keys", "-t", SESSION, line, "Enter"])
    time.sleep(0.3)
    if not wait_prompt(timeout):
        return None
    lines = [l for l in pane() if l != ""]
    out = lines[before:]            # the echoed command, the output, the fresh prompt
    if out and out[0].startswith("jojo> "):
        out = out[1:]
    if out and out[-1] == "jojo>":
        out = out[:-1]
    return "\n".join(out)


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "tests", "atl", "readme-red.atl")
    name, steps, _sig = parse_case(path)
    subprocess.run(["tmux", "clear-history", "-t", SESSION])
    if not wait_prompt(600):
        sys.exit("repl-test: no prompt")
    bad = 0
    t0 = time.time()
    for inp, expects, refuse in steps:
        t = time.time()
        got = send(inp)
        dt = time.time() - t
        if got is None:
            print(f"FAIL  {inp!r}: no prompt after 120 s"); bad += 1; continue
        if refuse is not None:
            ok = got.startswith(refuse); want = refuse
        else:
            want = "\n".join(expects)
            # a blank line is the kernel's silent answer (it sends one space)
            ok = got.strip() == want.strip()
        bad += 0 if ok else 1
        print(f"{'ok  ' if ok else 'FAIL'}  [{dt:4.1f} s]  {inp}" + ("" if ok else f"\n      want {want!r}\n      got  {got!r}"))
    print(f"repl-test: {len(steps) - bad}/{len(steps)} lines reproduce at the prompt ({time.time() - t0:.0f} s)")
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
