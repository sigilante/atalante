#!/usr/bin/env python3
"""kernel-test.py: decode the kernel vector's product and check it.

The product is [effects peek]: one effect list per poked line, each
effect [%markdown text], and the peeked environment noun. The expect
file names, per poked line, the text the kernel printed, then
`peek NAME: v1 v2 ...` rows naming arrays the store must hold.
"""
import sys
sys.set_int_max_str_digits(0)


def cue(a):
    refs = {}
    def rub(b):
        c = 0
        while not (a >> (b + c)) & 1:
            c += 1
        if c == 0:
            return 0, b + 1
        bl = ((a >> (b + c + 1)) & ((1 << (c - 1)) - 1)) | (1 << (c - 1)) if c > 1 else 1
        pos = b + c + 1 + (c - 1)
        return (a >> pos) & ((1 << bl) - 1), pos + bl
    def go(b):
        if not (a >> b) & 1:
            v, nb = rub(b + 1); refs[b] = v; return v, nb
        if not (a >> (b + 1)) & 1:
            h, nb = go(b + 2); t, nb2 = go(nb); refs[b] = (h, t); return (h, t), nb2
        v, nb = rub(b + 2); return refs[v], nb
    return go(0)[0]


def lst(n):
    out = []
    while n != 0:
        out.append(n[0]); n = n[1]
    return out


def cord(n):
    return n.to_bytes((n.bit_length() + 7) // 8, "little").decode("utf-8") if n else ""


def ray_vals(ray):
    meta, data = ray
    shape = lst(meta[0])
    bloq = meta[1][0]
    n = 1
    for d in shape:
        n *= d
    w = 1 << bloq
    return shape, [(data >> (w * i)) & ((1 << w) - 1) for i in range(n)]


def main(out_jam, lines_file, expect_file):
    data = open(out_jam, "rb").read()
    fx, peek = cue(int.from_bytes(data, "little"))
    lines = [l for l in open(lines_file, encoding="utf-8").read().split("\n") if l.strip()]
    printed = []
    for effs in lst(fx):
        texts = [cord(e[1]) for e in lst(effs) if e[0] == int.from_bytes(b"markdown", "little")]
        printed.append("\n".join(t for t in texts if t != " "))
    store = lst(peek[0])
    arrays = {cord(nm): ray_vals(arr[1]) for nm, arr in store}
    want_lines, want_peeks = [], []
    for ln in open(expect_file, encoding="utf-8").read().split("\n"):
        if ln.startswith("peek "):
            nm, _, vals = ln[5:].partition(":")
            want_peeks.append((nm.strip(), [int(v) for v in vals.split()]))
        elif ln.startswith("line "):
            want_lines.append(ln[5:])
    bad = 0
    for i, (inp, want) in enumerate(zip(lines, want_lines)):
        got = printed[i] if i < len(printed) else "<missing>"
        ok = got == want
        bad += 0 if ok else 1
        print(f"{'ok  ' if ok else 'FAIL'}  poke {inp!r} -> {got!r}" + ("" if ok else f"  (want {want!r})"))
    for nm, vals in want_peeks:
        got = arrays.get(nm)
        ok = got is not None and got[1] == vals
        bad += 0 if ok else 1
        print(f"{'ok  ' if ok else 'FAIL'}  peek {nm}: {got[1] if got else None} shape {got[0] if got else None}")
    print(f"kernel-test: {len(want_lines) + len(want_peeks) - bad}/{len(want_lines) + len(want_peeks)} checks pass")
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:4]))
