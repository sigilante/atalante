#!/usr/bin/env python3
"""gnu-import.py: rewrite GNU APL's session-format testcases (src/testcases/*.tc in the GNU APL
tree) as Atalante corpus cases (tests/gnu/*.atl).

  tools/gnu-import.py GNU_TESTCASES_DIR OUT_DIR FILE.tc ...

A .tc file is a recorded session: input lines indented six spaces, each followed by the output
GNU APL printed, and function definitions as column-0 lines from `∇header` to `∇`.  Each step
becomes a `🍎>` line with `⍝ expect:` lines; an output that opens with an error name becomes a
`⍝ refuse:` with Atalante's tag.  GNU's spellings are rewritten (ρ ι ◊ → ⍴ ⍳ ⋄), a `)CLEAR`
starts a new case (a fresh session), and a step Atalante cannot express is kept as a comment
naming why, so every skip is visible in the output.
"""
import os, re, sys

ATL_GLYPHS = set("¨¯×÷←↑↓∇∈∊−∘∣∧∨∼≠≡≢≤≥⊂⊃⊖⊢⊣⊤⊥⋄⋆⌈⌊⌹⌽⌿⍀⍉⍋⍎⍒⍕⍝⍟⍪⍱⍲⍳⍴⍵⍷⍺⎕○∪∩⍬")
REWRITE = {"ρ": "⍴", "ι": "⍳", "◊": "⋄", "ϵ": "∊", "ε": "∊", "⍶": "⍺⍺", "⍹": "⍵⍵"}
ERRORS = {"DOMAIN ERROR": "%domain-error", "LENGTH ERROR": "%length-error", "RANK ERROR": "%rank-error",
          "INDEX ERROR": "%index-error", "VALUE ERROR": "%value-error", "SYNTAX ERROR": "%syntax-error",
          "AXIS ERROR": "%axis-error", "VALENCE ERROR": "%valence-error", "NONCE ERROR": "%unimplemented",
          "LIMIT ERROR": "%limit-error", "WS FULL": "%limit-error", "Bad number": "%syntax-error"}
SYSNAMES_OK = {"IO", "PP"}
WRAP = re.compile(r"      [0-9¯.E ]+")


def name_char(c):
    """a letter Atalante's lexer takes in a name (lexer.isLetter): ∆ ⍙, Greek, Cyrillic, Hebrew"""
    o = ord(c)
    return o in (8710, 9049) or 913 <= o <= 937 or 945 <= o <= 969 or 1040 <= o <= 1103 or 1488 <= o <= 1514


def rewrite(s):
    for a, b in REWRITE.items():
        s = s.replace(a, b)
    # a numeral GNU writes with a bare point, `.4` or `¯.3`, is `0.4` or `¯0.3` in Atalante (D-3);
    # only outside quotes, and only where no digit or name character precedes the point
    out, q = [], False
    for i, c in enumerate(s):
        if c == "'": q = not q
        if (not q) and c == "." and i + 1 < len(s) and s[i + 1].isdigit() and (i == 0 or not (s[i - 1].isalnum() or s[i - 1] in "_∆⍙")):
            out.append("0.")
        else:
            out.append(c)
    return "".join(out)


def drop_comment(s):
    """the input without a trailing ⍝ comment (outside quotes):  it carries no behaviour, and a long one
    wraps the REPL pane the harness reads"""
    q = False
    for i, c in enumerate(s):
        if c == "'": q = not q
        elif c == "⍝" and not q and s[:i].strip(): return s[:i].rstrip()
    return s


def unsupported(inp):
    """why Atalante cannot run this input, or None"""
    body = inp.split("⍝", 1)[0] if "'" not in inp else inp
    if re.search(r"(?<![A-Za-z])\d*\.?\d+J[¯\d.]", body): return "complex numbers"
    if '"' in body: return "double-quoted strings"
    if "→" in body: return "branch"
    if "⍞" in body: return "quote-quad"
    for m in re.finditer(r"⎕([A-Za-z]*)", body):
        if m.group(1).upper() not in SYSNAMES_OK: return f"system name ⎕{m.group(1)}"
    in_q = False
    for c in body:
        if c == "'": in_q = not in_q; continue
        if in_q: continue
        if ord(c) > 127 and c not in ATL_GLYPHS and not name_char(c): return f"glyph {c}"
    if body.lstrip().startswith(")") and not body.lstrip().upper().startswith(")ERASE"): return "system command"
    if body.lstrip().startswith("]"): return "user command"
    return None


def parse(lines):
    """[(kind, payload)]: ('in', text), ('out', [lines]), ('def', [lines]), ('clear', None)"""
    steps, i, n = [], 0, len(lines)
    while i < n:
        l = lines[i].rstrip("\n")
        if "«««" in l:                    # a multi-line literal (GNU's ⊣««« … »»» comment blocks): not session input
            while i < n and "»»»" not in lines[i]: i += 1
            i += 1; continue
        if l.startswith("      "):
            inp = l[6:]
            out = []
            j = i + 1
            # output is unindented, or indented past column 6 (centred text such as a Pascal triangle);
            # an input starts at column 6 exactly, and a caret line belongs to an error
            def is_out(m):
                if m.startswith("∇") or m.startswith("⍝"): return False
                if not m.startswith("      "): return True
                return m.startswith("       ") and not caret(m)
            while j < n and is_out(lines[j]):
                out.append(lines[j].rstrip("\n")); j += 1
                # GNU wraps a long numeric row at ⎕PW 80 and indents the rest six spaces, like input;
                # Atalante does not wrap, so a numeric continuation joins the row it continues
                while j < n and out and len(out[-1]) >= 70 and WRAP.fullmatch(lines[j].rstrip("\n")):
                    out[-1] = out[-1].rstrip() + " " + lines[j].strip(); j += 1
            while out and out[-1].strip() == "": out.pop()
            # an error is recorded as its name, then the input echoed and a caret line, both indented
            # like input: they belong to this step
            # (any error, by any name:  the echo is the input again and a caret line follows it)
            if out and j + 1 < n and lines[j].startswith("      ") and lines[j][6:].rstrip("\n").strip() == inp.strip() and caret(lines[j + 1]):
                j += 2
            # GNU echoes the failing line in its own normal form (`3550579489682168305 +/ 1 2 3 4 5`
            # comes back as `3550579489682168305+/1 2 3 4 5`), so after an error a line with a caret
            # line under it is the echo whatever its spelling
            elif errtag(out) and j + 1 < n and lines[j].startswith("      ") and caret(lines[j + 1]):
                j += 2
            elif errtag(out):
                while j < n and lines[j].startswith("      ") and (lines[j][6:].rstrip("\n").strip() == inp.strip() or caret(lines[j])):
                    j += 1
            if inp.strip().upper() == ")CLEAR": steps.append(("clear", None))
            else: steps.append(("step", (inp, out)))
            i = j
        elif l.startswith("∇") and l.strip() != "∇":
            body = [l]; j = i + 1
            while j < n and lines[j].rstrip("\n").strip() != "∇": body.append(lines[j].rstrip("\n")); j += 1
            body.append("∇"); steps.append(("def", body)); i = j + 1
        else:
            i += 1
    return steps


def caret(m):
    """a caret line:  the column marks under an echoed input"""
    return bool(m.strip()) and set(m.strip()) <= set("^ ")


def errtag(out):
    """Atalante's tag for GNU's error, `?NAME` for a GNU-only error name, or None"""
    if not out: return None
    first = out[0].rstrip("+").strip()
    for name, tag in ERRORS.items():
        if first.startswith(name): return tag
    if re.fullmatch(r"[A-Z]+( [A-Z]+)* (ERROR|FULL)", first): return "?" + first
    return None


def convert(name, lines):
    cases, cur, stats = [], [], {"steps": 0, "skipped": 0, "defs": 0, "reasons": {}}
    def flush():
        if cur: cases.append(list(cur))
        cur.clear()
    for kind, pay in parse(lines):
        if kind == "clear": flush(); continue
        if kind == "def":
            hdr = rewrite(pay[0])
            why = "operator header" if re.match(r"∇\s*[A-Za-z_∆⍙]*\s*←?\s*\(", hdr) or re.search(r"\(\s*[A-Za-z_]+\s+[A-Za-z_]+\s+[A-Za-z_]+\s*\)", hdr) else None
            why = why or next((w for w in (unsupported(rewrite(b)) for b in pay[1:-1] + [hdr[1:]]) if w), None)
            if why:
                stats["skipped"] += 1; stats["reasons"][why] = stats["reasons"].get(why, 0) + 1
                cur.append(f"⍝ skipped ({why}): {hdr}"); continue
            stats["defs"] += 1
            cur.append("🍎> " + hdr)
            cur.extend("\t" + re.sub(r"^\[\d+\]\s*", "", rewrite(b)).strip() for b in pay[1:-1])
            cur.append("\t∇")
            continue
        inp, out = pay
        inp = drop_comment(rewrite(inp))
        if inp.strip().startswith("⍝") or inp.strip() == "" or caret(inp): continue
        stats["steps"] += 1
        why = unsupported(inp) or (None if not any("J" in o and re.search(r"\dJ", o) for o in out) else "complex numbers")
        if why:
            stats["skipped"] += 1; stats["reasons"][why] = stats["reasons"].get(why, 0) + 1
            cur.append(f"⍝ skipped ({why}): {inp.strip()}"); continue
        tag = errtag(out)
        if tag and tag.startswith("?"):
            why = "GNU-only error " + tag[1:]
            stats["skipped"] += 1; stats["reasons"][why] = stats["reasons"].get(why, 0) + 1
            cur.append(f"⍝ skipped ({why}): {inp.strip()}"); continue
        cur.append("🍎> " + inp.strip())
        if tag: cur.append("⍝ refuse: " + tag)
        else: cur.extend("⍝ expect: " + rewrite(o) for o in out)
    flush()
    return cases, stats


def main():
    src, outdir, files = sys.argv[1], sys.argv[2], sys.argv[3:]
    os.makedirs(outdir, exist_ok=True)
    total = {"steps": 0, "skipped": 0, "defs": 0, "reasons": {}}
    for f in files:
        base = os.path.splitext(os.path.basename(f))[0]
        lines = open(os.path.join(src, f), encoding="utf-8", errors="replace").readlines()
        cases, st = convert(base, lines)
        for k in ("steps", "skipped", "defs"): total[k] += st[k]
        for r, c in st["reasons"].items(): total["reasons"][r] = total["reasons"].get(r, 0) + c
        for i, c in enumerate(cases):
            nm = base if len(cases) == 1 else f"{base}-{i + 1}"
            if not any(l.startswith("🍎>") for l in c): continue
            # GNU APL prints a box in APL2's layout, which Atalante gives under )DISPLAY APL2 (D-99)
            hdr = [f"⍝ from GNU APL {f} (GPLv3, tests/gnu/README.md)", "🍎> )DISPLAY APL2", "⍝ expect: display APL2"]
            open(os.path.join(outdir, nm + ".atl"), "w", encoding="utf-8").write("\n".join(hdr + c) + "\n")
    print(f"steps {total['steps']}, runnable {total['steps'] - total['skipped']}, skipped {total['skipped']}, definitions {total['defs']}")
    for r, c in sorted(total["reasons"].items(), key=lambda x: -x[1]): print(f"  {c:5d}  {r}")


if __name__ == "__main__":
    main()
