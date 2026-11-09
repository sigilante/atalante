# Atalante — Roadmap

**Status: P8, P9 and P10 landed 2026-11-03; P11 landed 2026-11-04 on the float half of its exit; P11b is profiled with its first fixes in; the rest of §9 and P12 landed the same day; the GNU APL suite (P13) landed 2026-11-07, its first missing features (P14), APL2's display (P15) and roll and deal (P16) and the next tier of features (P17) on 2026-11-09, and the operators (P18) and gamma with exact naturals (P19) on 2026-11-10; the rest of P11b, the suite's other missing features, complex numbers and the hosts remain.** v0.1.1 implements dialect v1 in full ([release notes](release-v0.1.md)). This file carries what comes after, in the plan's shape: numbered phases from P8, each with its scope, the rules it closes, a mechanical exit test, and what it waits on. The order below is a dependency order and a recommendation; the maintainer rules it. A phase lands as the P0–P7 phases did ([plan.md §3](plan.md)): with its vectors, recorded in the plan with numbers, and the spec's rules pinned.

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

**P12 — The deferred rulings (ruled 2026-11-04).** D-8: bare ASCII words in a `)ASCII ON` session mode, one lowercase word per glyph, rewritten ahead of the lexer with columns kept. D-15: `⎕TYPE` as a per-kind storage width, `UINT8`–`UINT64`, `INT8`–`INT64` and `REAL16`–`REAL128`, which means the array model leaves bloq 6, D-11's promotion learns mixed widths, and every primitive wraps or rounds at its width. S-24, the column a green-prompt refusal blames: the rightmost unbound name, as evaluation order would.
*Exit:* a corpus case typed in ASCII under `)ASCII ON` gives the Unicode case's output; `⎕TYPE` vectors for every name, wrapping and rounding at each width; S-24's refusal blames column 25 on the README sieve with R unbound.
*Waits on:* nothing: both rulings are in. D-15 is the larger half.
**LANDED 2026-11-04** ([plan §3](plan.md)): `)ASCII ON` with a 51-word table, `⎕TYPE` as per-kind widths through width-dispatching float arms, and S-24's column. The README typed in ASCII gives the Unicode output, 30/30; `⎕TYPE` wraps and rounds at every width in `atl/types` (P13 replaced the wrap with a DOMAIN ERROR, D-15 ruled 2026-11-07); the sieve refuses at column 25.

**P13 — GNU APL's testcases (2026-11-06..07).** GNU APL's session-format testcases, rewritten for Atalante by `tools/gnu-import.py` into `tests/gnu/` (GPLv3 test data, never built or shipped), run at the prompt and sorted into Atalante bugs, dialect differences and unruled GNU behaviour ([docs/gnu-apl-suite.md](gnu-apl-suite.md)). Rulings: D-96 (an axis on a scalar function); D-15, integer overflow a DOMAIN ERROR at every width with no promotion to real; D-11, a mixed comparison through the real; and GNU's error order (D-23, D-40, D-82, D-89, D-90).
*Exit:* the suite runs end to end with no kernel crash, and every bug it found has a corpus vector.
**LANDED 2026-11-07:** 1,772 of 2,864 typed lines reproduce GNU's output and 1,357 steps are skipped with their reasons; `atl/types`, `atl/scalar-axis` and `atl/gnu-order` pin the fixes. Next, in the maintainer's order of triage: a session setting for APL2's nested display, which at least 137 failures differ by alone; the missing features (`⍬ ∪ ∩ ∼` and n-wise reduction first; roll and deal, selective and strand assignment, and `⍤` need rulings or more design); exact mixed natural-integer arithmetic, so a natural of 2^63 or more can meet an integer; and complex numbers through Lagoon's `/lib/complex`.

**P14 — The suite's first missing features (2026-11-09).** `⍬`, the set functions `∪ ∩ ∼`, and n-wise reduction with and without an axis, the first tier of the suite's triage (D-97, D-98). `A∪B` follows GNU APL's symmetric definition, `∪A,B`, rather than Dyalog's `A,B∼A`. Under `)ASCII ON` the new words are `downshoe`, `upshoe` and `zilde`.
*Exit:* `atl/sets` and `atl/nwise` pass in every lane and at the prompt, and the suite's Union, Intersection, Without, Zilde and Reduce_N_wise cases fail only where nested display or a missing feature explains it.
**LANDED 2026-11-09:** 1,862 of 2,816 typed lines reproduce GNU's output, up from 1,772; the corpus is 836/836 and parse 143/143. The importer no longer types GNU's respelled error echoes as steps, which removed 106 typed lines. Next tier: APL2's display, then `∧ ∨` as LCM and GCD, the hyperbolic circle codes, negative replicate, pick through a scalar box, and multiple `⍕` pairs.

**P15 — APL2's display as a setting (2026-11-09).** `)DISPLAY APL2` prints a box in IBM APL2's layout as GNU APL prints it, and `)DISPLAY STRAND` keeps the strand, the default (D-99). Columns part by APL2's spacing rule (LRM p. 138), and `⍕` follows the setting. The GNU cases run under it.
*Exit:* `atl/display-apl2` passes in every lane and at the prompt, and no GNU case loses a line.
**LANDED 2026-11-09:** 2,024 of 2,816 typed GNU lines reproduce, up from 1,862.

**P16 — Roll, deal and `⎕RL` (2026-11-09).** `?B` and `A?B` draw from one Philox4x32-10 stream per session, from numerics' `/lib/rand` (vendored at the same pin, 0611fac; not cryptographic). Jojo's `eny` seeds the stream at the first line, and `⎕RL←n` reseeds it so a run repeats (D-104). Deal is Floyd's sampling in Knuth's ordering, quadratic in `A`.
*Exit:* `atl/roll-deal` passes in every lane and at the prompt.
**LANDED 2026-11-09.** GNU's own roll and deal numbers come from its generator, so its `Roll` and `Deal` cases cannot match them (a dialect difference, not a failure to fix).

**P17 — The next tier (2026-11-09).** `∨ ∧` as GCD and LCM, a real dividing as its shortest decimal (D-100); the hyperbolic circle codes (D-101); `⍕` rounding the exact binary value, with a `W D` pair per column and exponent form (D-102); negative replicate and pick through a box path (D-103).
*Exit:* `atl/next-tier` passes in every lane and at the prompt, and no GNU case loses a line.
**LANDED 2026-11-09:** 2,073 of 2,816 typed GNU lines reproduce, up from 2,024.

**P18 — The operators `⍨ ⍣ ⍤` (2026-11-10).** Primitive operators through the dfn-operator form (D-105), parenthesised derived functions such as `2 (+⍣40) 5`, and `⍤` over empty cells.
*Exit:* `atl/operators` passes in every lane and at the prompt.
**LANDED 2026-11-10** with P19.

**P19 — Gamma and exact naturals (2026-11-10).** `!` of a fraction through Lanczos's Γ with a log-gamma fallback, APL2's negative binomials (D-106); naturals past 2^63 meeting integers exactly (D-107); integer numerals past 64 bits refuse. A Wizard review found and closed silent wrong answers in D-100, D-101 and D-106 before the merge.
*Exit:* `atl/gamma` and `atl/exact-ni` pass in every lane and at the prompt, and the reviews pass.
**LANDED 2026-11-10:** 2,143 of 2,930 typed GNU lines reproduce.

## Performance

**P11 — The jetted array core.** The plan's P7 finding stands: Lagoon's reductions and `+bin-op` cost more under NockVM than a Jock fold (S-22), and NockVM has no float jets (S-4), so reals cost ~0.3 ms an operation. The way out is the packed erasure of plan §1.1 with jets that match it: SoftBLAS or NockVM float jets for the rd door, a linear `+bin-op` and a `+roll` over the ravel upstream in Lagoon, and a `%box` layout for P9. The specialised gates of P7 stay the differential: every gate re-checks its precondition and falls back, so the corpus holds the value while the numbers move.
*Exit:* `tools/bench.sh` at 1e5 elements: the generic `+/` under 1 s and a float `+/` within 10× of the natural one; the corpus unchanged.
*Waits on:* S-22 upstream (numerics), float jets in NockVM, or SoftBLAS; this is the phase with the most outside it.
**LANDED 2026-11-04 on the float half** ([plan §3](plan.md)); the maintainer ruled the natural half over to P11b: S-22 closed upstream (numerics #94, vendored), and the float jets reach the jojo host through its hot table (jojo's runtime at nockchain b9dd5af). A float `+/` at 1e5 costs 7.6× the natural one, so that half holds; the generic `+/` costs 3.7 s, which waits on `%uint` jets for Lagoon's integer arms. The `%box` layout needs no jet of its own: a box's structural work runs on its `%uint` index ray, and no arithmetic runs over its items. The exit's numbers come from `tools/bench-repl.py` under jojo, since `tools/bench.sh` runs on honk-kick, which carries no jets.

**P11b — The natural fold and the Jock-side costs.** P11 left the generic `+/` over 1e5 naturals at 3.7 s under jojo, against P11's 1 s target. The float jets cannot reach it, and at that size two Jock-side costs dominate everything else: printing 1e5 reals takes ~230 s and `v ← ⍳100000` takes ~173 s. Three candidates, to measure before choosing. The first is integer paths in lagoon-jets (`add-rays`, `sub-rays`, `mul-rays`, `cumsum`, `max`, `min` on `%uint` and `%int2`), checked bit for bit under `NOCK_TEST_JETS` and reached by re-exporting the folds from the package for `g-reduce`. The second is the session's double run, since every red statement evaluates through both the interpreter and the emitter. The third is the display and `⍳` paths in `src/array.jock` and `src/interp.jock`.
*Exit:* `tools/bench-repl.py 100000` under jojo shows the generic `+/v` under 1 s, `1.5×v` printed in under 10 s, and `v ← ⍳100000` in under 10 s; the corpus unchanged.
*Waits on:* a profile of the 3.7 s; Rust in jojo's lagoon-jets only if the profile points at the fold.
**PROFILED 2026-11-04** ([plan §3](plan.md)). The cost is NockVM copying a non-tail call's cells out of its frame, which makes every consing recursion quadratic. The 3.7 s was the interpreter half of the session's double run: the emitted `+/` alone takes 0.33 s. The hot builders are fixed, taking `⍳100000` from 179 s to 0.64 s and `1+v` from 115 s to 1.3 s. The sweep through display, `⍕` and the remaining builders is the open work, and no Rust is needed for it. **SWEPT 2026-11-06**: about 80 builders are now tail-recursive, joins are linear, gathers are O(n log n) and grade is a merge sort. `⍴⍕v` at 30,000 elements drops from 345 s to 2.2 s, and a transpose from 219 s to 0.3 s. What remains is printing reals, about 0.9 ms an element in Hoon's `+drg`.

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
