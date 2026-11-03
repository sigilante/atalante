# Atalante — Roadmap

**Status: P8, P9 and P10 landed 2026-11-03; P11 landed 2026-11-04 on the float half of its exit; P11b, P12 and the hosts remain.** v0.1.1 implements dialect v1 in full ([release notes](release-v0.1.md)). This file carries what comes after, in the plan's shape: numbered phases from P8, each with its scope, the rules it closes, a mechanical exit test, and what it waits on. The order below is a dependency order and a recommendation; the maintainer rules it. A phase lands as the P0–P7 phases did ([plan.md §3](plan.md)): with its vectors, recorded in the plan with numbers, and the spec's rules pinned.

Two facts fix most of the order. Nested arrays change the array model every structural function sits on, so they precede the primitives that need them (`⍷ ⍪ ≡`, dyadic `⍕`). Dfns need `⍺ ⍵` and guards in the parser before the emitter can see them, so they are a phase of their own and come first, since nothing else depends on them and they are what the v1 tradfn programmer reaches for next.

## Language

**P8 — Dfns with guards (D-32, RULED).** `{⍺ ⍵}` bodies with `cond: expr` guards, `⍺` and `⍵` as the implicit arguments, nested dfns, dfns as operator operands. A dfn is a function value in the store with the same name classes as a tradfn (D-52), compiles on first call under the D-34 cache, and runs through both the interpreter and the emitted Nock. `→` and labels stay out for good.
*Exit:* a dfn version of every README tradfn (`DIV`, `CaesarCipher`) gives the same output; a guarded `{⍵≤1: 1 ⋄ ⍵×∇ ⍵-1}` factorial, recursive through `∇`, agrees between interpreter and emitter on the corpus; a dfn as a `/` operand.
**LANDED 2026-11-03** as D-63..D-69 ([plan §3](plan.md)). Left for a later phase: dfn operators (`⍺⍺ ⍵⍵`), a default left argument (`⍺←`), error guards (`::`), a dfn as the operand of `.` or `∘.`.

**P9 — Nested arrays (D-6).** The `%box` element kind: a strand of character vectors, `⊂` enclose, `⊃` disclose and pick, `≡` depth, display of nested arrays. The ruled-out alternative, a rank-2 character matrix idiom, is revisited here before the kind enters. Every v1 primitive keeps its value on flat arrays, and the corpus is the regression test for that.
*Exit:* the README's `X ← 'sing' 'goddess' 'sing' 'of' 'the' 'rage'`, `⍋X`, `X[⍋X]` as the 2024 README printed them; v1 corpus unchanged; `≡` on flat and nested vectors.
*Waits on:* P8 is independent; the array model's Lagoon layout (plan §1.1) has no boxed kind, so `%box` is a Jock-side list of rays until P11.
**LANDED 2026-11-03** as D-70..D-77 ([plan §3](plan.md)); the maintainer ruled for `%box`, scoped narrowly. The items first left out (partition, `≢`, `⊃` in full, reductions and scans over a box of any rank, inner and outer products over boxes) landed the same day as D-78..D-81; the `%box` layout is P11.

**P10 — The held-back primitives (D-44) and axis specification.** `⍷` find, `⍪` table and laminate, dyadic `⍉`, `⌽` and `⊖` with axis, `f/[k]` and `f\[k]` on an axis, `↑ ↓` past rank 1, `⊥ ⊤` past naturals, reductions and scans past rank 2, dyadic `⍕` format, derived-function operands to operators, `⍎` execute through the compiler in the runtime (plan P6 made it cheap), `⌹` matrix divide on a float solver.
*Exit:* three vectors per glyph, as D-41 required; `⍎` of each README line equals the line typed; `⌹` on a 3×3 system against a hand-checked answer.
*Waits on:* `⌹` waits on P11's float path; P9 has landed, so `⍷ ⍪` take nested arguments from the start.
**LANDED 2026-11-03** as D-82..D-91 ([plan §3](plan.md)), with the rest of nesting (D-78..D-81). `⌹` runs on Jock's float scalar path without waiting for P11; a fractional axis (laminate) stays out.

**P12 — The deferred rulings.** D-8, an ASCII input pre-pass with its own table and vectors (`iota` for `⍳` and the like), never a grammar change. D-15, what `⎕TYPE` names once the array model has more than bloq 6: a storage width or a default literal kind. S-24, the column a green-prompt refusal blames: the rightmost unbound name, as evaluation order would.
*Exit:* a corpus case typed in ASCII gives the Unicode case's output; `⎕TYPE` vectors for whichever meaning is ruled; S-24's refusal blames column 25 on the README sieve with R unbound.
*Waits on:* P11 for D-15.

## Performance

**P11 — The jetted array core.** The plan's P7 finding stands: Lagoon's reductions and `+bin-op` cost more under NockVM than a Jock fold (S-22), and NockVM has no float jets (S-4), so reals cost ~0.3 ms an operation. The way out is the packed erasure of plan §1.1 with jets that match it: SoftBLAS or NockVM float jets for the rd door, a linear `+bin-op` and a `+roll` over the ravel upstream in Lagoon, and a `%box` layout for P9. The specialised gates of P7 stay the differential: every gate re-checks its precondition and falls back, so the corpus holds the value while the numbers move.
*Exit:* `tools/bench.sh` at 1e5 elements: the generic `+/` under 1 s and a float `+/` within 10× of the natural one; the corpus unchanged.
*Waits on:* S-22 upstream (numerics), float jets in NockVM, or SoftBLAS; this is the phase with the most outside it.
**LANDED 2026-11-04 on the float half** ([plan §3](plan.md)); the maintainer ruled the natural half over to P11b: S-22 closed upstream (numerics #94, vendored), and the float jets reach the jojo host through its hot table (jojo's runtime at nockchain b9dd5af). A float `+/` at 1e5 costs 7.6× the natural one, so that half holds; the generic `+/` costs 3.7 s, which waits on `%uint` jets for Lagoon's integer arms. The `%box` layout needs no jet of its own: a box's structural work runs on its `%uint` index ray, and no arithmetic runs over its items. The exit's numbers come from `tools/bench-repl.py` under jojo, since `tools/bench.sh` runs on honk-kick, which carries no jets.

**P11b — The natural fold and the Jock-side costs.** P11 left the generic `+/` over 1e5 naturals at 3.7 s under jojo, against P11's 1 s target. The float jets cannot reach it, and at that size two Jock-side costs dominate everything else: printing 1e5 reals takes ~230 s and `v ← ⍳100000` takes ~173 s. Three candidates, to measure before choosing. The first is integer paths in lagoon-jets (`add-rays`, `sub-rays`, `mul-rays`, `cumsum`, `max`, `min` on `%uint` and `%int2`), checked bit for bit under `NOCK_TEST_JETS` and reached by re-exporting the folds from the package for `g-reduce`. The second is the session's double run, since every red statement evaluates through both the interpreter and the emitter. The third is the display and `⍳` paths in `src/array.jock` and `src/interp.jock`.
*Exit:* `tools/bench-repl.py 100000` under jojo shows the generic `+/v` under 1 s, `1.5×v` printed in under 10 s, and `v ← ⍳100000` in under 10 s; the corpus unchanged.
*Waits on:* a profile of the 3.7 s; Rust in jojo's lagoon-jets only if the profile points at the fold.

## Hosts and tooling

**H1 — A Gall `%sole` host (S-6).** The 2024 shoe agent is in history at b721975 and is a shape, not a base. A Gall agent holds the Jock-compiled kernel as a noun and fires it with raw Nock: poke `[%command line]` in, `[%markdown text]` and `[%prompt text]` effects out, the same ABI jojo speaks. The bridge from a Jock func value to Hoon is untyped and unbuilt; the kernel's effects are tagged cells, which is enough for a `%sole` driver.
*Exit:* the README transcript typed at a ship's dojo through `|link`, every line as the jojo transcript prints it, apples included.
*Waits on:* nothing in this repo; a day of Hoon.

**H2 — jonk as the inner loop (S-3).** The native Rust Jock compiler, once its branch is rebased on the pinned Jock: `tools/atlc.sh` already wraps both lanes. The honk lane stays the authority; jonk turns the 3.5-minute compile into seconds for the corpus and the kernel.
*Exit:* the corpus under jonk agrees with the honk lane, 262/262; `atlc.sh corpus` under jonk in under a minute.
*Waits on:* the jonk rebase, upstream.

**H3 — Dropping the workarounds as upstream lands.** S-11 (module function as a value: the named wrappers in `src/interp.jock` go), S-12 (the honk literal sign: the vendored numerics return to their original spelling through `tools/vendor-numerics.py`), S-21 and S-23 (Lagoon's `prod` and `+change`: the guards go), S-19 (the poke shape: the kernel's second match arm goes once the trait names one shape). Each is a one-commit change with the corpus as its test.
*Exit:* the ledger row CLOSED, the workaround removed, the corpus unchanged.
*Waits on:* each fix merging upstream; the filings went out 2026-10-28.

## Not planned

`→` and labels (D-32 omitted them for good). A sealed kernel jam: it runs jetless under the current runtime (S-5), and the unsealed jam ships with jojo as `atalante.jam`, which embeds only Atalante's own module sources. A rewrite of the array model away from Lagoon: P7 measured the cost and moved the hot paths into Jock; P11 is the path back to jets, not away from rays.
