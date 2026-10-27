#!/usr/bin/env python3
"""goldens-oracle.py: an INDEPENDENT check of the emission goldens.

For every statement in tests/atl/goldens.atl that carries both a `:nock`
rendering (the vendored Hoon renderer's text) and a `:noun` golden (the
vendored Hoon expander's lowering, printed by the program), lower the
rendering with sigilante/nockasm's PYTHON implementation and require the
noun to be identical. That is the IR's round-trip law (nockasm-target.md
N-35) applied across two implementations: a golden the program pinned
from its own output is thereby checked by code the program never ran.

  tools/goldens-oracle.py [NOCKASM_CHECKOUT]   (default ~/Code/urbit/nockasm)
"""
import os, sys, re
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/Code/urbit/nockasm"))
import nockasm


def show(n):
    if isinstance(n, int):
        return str(n)
    parts = []
    while isinstance(n, tuple):
        parts.append(show(n[0]))
        n = n[1]
    parts.append(show(n))
    return "[" + " ".join(parts) + "]"


def cases(path):
    nock, noun = {}, {}
    cur = None
    for line in open(path, encoding="utf-8").read().split("\n"):
        if line.startswith("🍏> :nock "):
            cur = ("nock", line[len("🍏> :nock "):])
        elif line.startswith("🍏> :noun "):
            cur = ("noun", line[len("🍏> :noun "):])
        elif line.startswith("⍝ expect:") and cur:
            text = line[len("⍝ expect:"):]
            text = text[1:] if text.startswith(" ") else text
            (nock if cur[0] == "nock" else noun).setdefault(cur[1], []).append(text)
        else:
            cur = None
    return nock, noun


def main():
    nock, noun = cases(os.path.join(ROOT, "tests", "atl", "goldens.atl"))
    both = [s for s in noun if s in nock]
    bad = 0
    for stmt in both:
        sch, ast = nockasm.parse("\n".join(nock[stmt]))
        got = show(nockasm.lower(sch, ast))
        want = "\n".join(noun[stmt])
        ok = got == want
        bad += 0 if ok else 1
        print(f"{'ok  ' if ok else 'FAIL'}  {stmt}")
        if not ok:
            print(f"      python: {got}\n      golden: {want}")
    print(f"oracle: {len(both) - bad}/{len(both)} goldens agree with the Python expander")
    return 0 if bad == 0 and both else 1


if __name__ == "__main__":
    sys.exit(main())
