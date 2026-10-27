#!/usr/bin/env python3
"""vendor-numerics.py: copy Lagoon and its libraries from the numerics
checkout into vendor/numerics and apply the honk patches, so re-vendoring
is one command and every patch is a rule, not a hand edit.

  tools/vendor-numerics.py [NUMERICS_CHECKOUT]   (default ~/Code/urbit/numerics)

The three rules (vendor/NUMERICS.txt):
  1. trailing `::` comments are stripped from /+ /- /= import lines.
  2. `..part` becomes `+` in ~% jet parents (hoon-138 has no +part).
  3. every @r literal is rewritten as a plain decimal with a fractional
     part and no exponent: honk sets the sign bit of a positive @r
     literal whose decimal exponent is >= 0 (`.~1` -> -1.0, `.~1.5e2`
     -> -150.0; `.~0.5` and `.~1.0e-10` are right; the Urbit dojo gets
     all of them right). `.~1` -> `.~1.0`, `.~1.5e2` -> `.~150.0`.
"""
import os, re, sys, subprocess
from decimal import Decimal

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/Code/urbit/numerics")
FILES = {
    "sur/lagoon.hoon": "lagoon/desk/sur/lagoon.hoon",
    "lib/lagoon.hoon": "lagoon/desk/lib/lagoon.hoon",
    "lib/twoc.hoon": "libmath/desk/lib/twoc.hoon",
    "lib/unum.hoon": "libmath/desk/lib/unum.hoon",
    "lib/complex.hoon": "libmath/desk/lib/complex.hoon",
    "lib/fixed.hoon": "libmath/desk/lib/fixed.hoon",
    "lib/math.hoon": "libmath/desk/lib/math.hoon",
}
LIT = re.compile(r"(?<![A-Za-z0-9.])\.(~{0,3})(-?)(\d+(?:\.\d+)?)(?:e(-?\d+))?(?![\w.])")


def fix_lit(m):
    tildes, sign, mant, exp = m.groups()
    d = Decimal(mant).scaleb(int(exp)) if exp is not None else Decimal(mant)
    s = format(d, "f")
    if "." not in s:
        s += ".0"
    return "." + tildes + sign + s


def patch(text):
    out = []
    for line in text.split("\n"):
        if re.match(r"^/[-+=]", line):
            line = re.sub(r"^(/[-+=].*?\S)\s+::.*$", r"\1", line)
        line = line.replace("..part", "+")
        line = LIT.sub(fix_lit, line)
        out.append(line)
    return "\n".join(out)


def main():
    rev = subprocess.run(["git", "-C", SRC, "rev-parse", "HEAD"], capture_output=True, text=True).stdout.strip()
    n = 0
    for dst, src in FILES.items():
        text = open(os.path.join(SRC, src), encoding="utf-8").read()
        patched = patch(text)
        n += len(LIT.findall(text))
        path = os.path.join(ROOT, "vendor", "numerics", dst)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, "w", encoding="utf-8").write(patched)
    open(os.path.join(ROOT, "vendor", "NUMERICS.txt"), "w", encoding="utf-8").write(
        f"numerics pin: the numerics checkout at {rev} (vendored by tools/vendor-numerics.py)\n"
        "files:\n" + "".join(f"  {d}  <- {s}\n" for d, s in FILES.items()) +
        "patches, applied by the script (so a re-vendor re-applies them):\n"
        "  1. trailing '::' comments stripped from /+ /- /= import lines --- honk's import\n"
        "     parser reads the whole line as the import.\n"
        "  2. '..part' -> '+' in the ~% jet-registration parents --- hoon-138 has no +part.\n"
        "     This changes the jet label PARENT; SoftBLAS jets on the vere fork would need\n"
        "     the original spelling (NockVM has no float jets either way).\n"
        f"  3. every @r literal ({n} of them) rewritten as a plain decimal with a fractional\n"
        "     part and no exponent. honk sets the SIGN BIT of a positive @r literal whose\n"
        "     decimal exponent is >= 0: .~1 -> -1.0, .1 -> -1.0, .~~1 -> -1.0, .~1.5e2 ->\n"
        "     -150.0, while .~0.5 and .~1.0e-10 parse right and the Urbit dojo parses all of\n"
        "     them right (checked on ~nec, 2026-10-27). The rewrite is value-preserving:\n"
        "     .~1 -> .~1.0, .~1.5e2 -> .~150.0. Filed as S-12 in docs/plan.md.\n")
    print(f"vendored at {rev[:7]}; {n} float literals normalized")


if __name__ == "__main__":
    main()
