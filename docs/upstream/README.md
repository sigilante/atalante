# Upstream patches

`hatch-mul-sign.patch` — nockchain `crates/hatch/src/utils.rs`, against
`9bcc26c6` (2026-10-19). `binaryfloat_mul` takes the sign-flip branch on a
zero-mantissa test where `binaryfloat_div` tests `sa == sb`, so every
positive `@r` literal whose decimal exponent is non-negative parses with
its sign bit set (`.~1` → `0xbff0…`, `.~1.5e2` → −150). Built and
verified 2026-10-27: the patched honk parses `.~1 .1 .~~1 .~1.5e2 .~-1
.~0.5 .~1.0e-10 .~-0.5e1` all correctly, `cargo test -p hatch` passes,
and the unpatched numerics libraries give `factorial 5` = 120 under it.
Ledger entry S-12 in `docs/plan.md`. Not yet opened as a PR.
