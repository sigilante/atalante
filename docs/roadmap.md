# Atalante — Roadmap

**Status: draft for the maintainer's ordering (2026-10-28).** v0.1.1 implements dialect v1 in full ([release notes](release-v0.1.md)). This file carries what comes after, in the plan's shape: numbered phases from P8, each with its scope, the rules it closes, a mechanical exit test, and what it waits on. The order below is a dependency order and a recommendation; the maintainer rules it. A phase lands as the P0–P7 phases did ([plan.md §3](plan.md)): with its vectors, recorded in the plan with numbers, and the spec's rules pinned.

Two facts fix most of the order. Nested arrays change the array model every structural function sits on, so they precede the primitives that need them (`⍷ ⍪ ≡`, dyadic `⍕`). Dfns need `⍺ ⍵` and guards in the parser before the emitter can see them, so they are a phase of their own and come first, since nothing else depends on them and they are what the v1 tradfn programmer reaches for next.

## Language

**P8 — Dfns with guards (D-32, RULED).** `{⍺ ⍵}` bodies with `cond: expr` guards, `⍺` and `⍵` as the implicit arguments, nested dfns, dfns as operator operands. A dfn is a function value in the store with the same name classes as a tradfn (D-52), compiles on first call under the D-34 cache, and runs through both the interpreter and the emitted Nock. `→` and labels stay out for good.
*Exit:* a dfn version of every README tradfn (`DIV`, `CaesarCipher`) gives the same output; a guarded `{⍵≤1: 1 ⋄ ⍵×∇ ⍵-1}` factorial, recursive through `∇`, agrees between interpreter and emitter on the corpus; a dfn as a `/` operand.
*Waits on:* nothing.

**P9 — Nested arrays (D-6).** The `%box` element kind: a strand of character vectors, `⊂` enclose, `⊃` disclose and pick, `≡` depth, display of nested arrays. The ruled-out alternative, a rank-2 character matrix idiom, is revisited here before the kind enters. Every v1 primitive keeps its value on flat arrays, and the corpus is the regression test for that.
*Exit:* the README's `X ← 'sing' 'goddess' 'sing' 'of' 'the' 'rage'`, `⍋X`, `X[⍋X]` as the 2024 README printed them; v1 corpus unchanged; `≡` on flat and nested vectors.
*Waits on:* P8 is independent; the array model's Lagoon layout (plan §1.1) has no boxed kind, so `%box` is a Jock-side list of rays until P11.

**P10 — The held-back primitives (D-44) and axis specification.** `⍷` find, `⍪` table and laminate, dyadic `⍉`, `⌽` and `⊖` with axis, `f/[k]` and `f\[k]` on an axis, `↑ ↓` past rank 1, `⊥ ⊤` past naturals, reductions and scans past rank 2, dyadic `⍕` format, derived-function operands to operators, `⍎` execute through the compiler in the runtime (plan P6 made it cheap), `⌹` matrix divide on a float solver.
*Exit:* three vectors per glyph, as D-41 required; `⍎` of each README line equals the line typed; `⌹` on a 3×3 system against a hand-checked answer.
*Waits on:* P9 for `⍷ ⍪ ≡` on nested arguments; `⌹` waits on P11's float path.

**P12 — The deferred rulings.** D-8, an ASCII input pre-pass with its own table and vectors (`iota` for `⍳` and the like), never a grammar change. D-15, what `⎕TYPE` names once the array model has more than bloq 6: a storage width or a default literal kind. S-24, the column a green-prompt refusal blames: the rightmost unbound name, as evaluation order would.
*Exit:* a corpus case typed in ASCII gives the Unicode case's output; `⎕TYPE` vectors for whichever meaning is ruled; S-24's refusal blames column 25 on the README sieve with R unbound.
*Waits on:* P11 for D-15.

## Performance

**P11 — The jetted array core.** The plan's P7 finding stands: Lagoon's reductions and `+bin-op` cost more under NockVM than a Jock fold (S-22), and NockVM has no float jets (S-4), so reals cost ~0.3 ms an operation. The way out is the packed erasure of plan §1.1 with jets that match it: SoftBLAS or NockVM float jets for the rd door, a linear `+bin-op` and a `+roll` over the ravel upstream in Lagoon, and a `%box` layout for P9. The specialised gates of P7 stay the differential: every gate re-checks its precondition and falls back, so the corpus holds the value while the numbers move.
*Exit:* `tools/bench.sh` at 1e5 elements: the generic `+/` under 1 s and a float `+/` within 10× of the natural one; the corpus unchanged.
*Waits on:* S-22 upstream (numerics), float jets in NockVM, or SoftBLAS; this is the phase with the most outside it.

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
