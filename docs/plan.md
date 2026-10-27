# Atalante — Implementation Plan

**Status: v1 released (2026-10-28; [release notes](release-v1.md)).** Atalante is rebuilt in Jock as a compiler from ATL/APL to Nock. The dialect is [`docs/spec/dialect.md`](spec/dialect.md); this file fixes the toolchain, the order of work, and each phase's exit test. The 2024 Hoon tree, `desk/`, was the glyph inventory and nothing more; it was removed at v1 and stays in history at b721975.

The project is also a shakedown of late-beta Jock. Every Jock gap it finds is recorded in §4 and filed upstream; a workaround in this tree names the gap it works around.

## 1. The dev loop

Three lanes, slowest is the authority.

| lane | tool | cost | role |
|---|---|---|---|
| inner | `jonk run` / `jonk check` / `jonk lsp` | 0.3–0.5 s per run, cache warm | every edit; the editor's diagnostics |
| authority | `tools/jockc.sh run` (honk-codex + honk-kick, NockVM) | ~14 s per run | the corpus lane in CI on every push; a jonk/honk disagreement is a Jock finding |
| product | `tools/kern.sh` → `jojo` | ~10 s build, then warm | the REPL kernel, poked `[%command line]`, as a user sees it |

**jonk** is the native Rust Jock compiler on the Jock repo's `bitemyapp/corrosion` branch (`crates/jonk`, Chris Allen, no PR as of 2026-10-27). Measured on this machine: release build 32 s; `jonk run` 0.3–0.5 s on small programs and on `examples/parser.jock` with the stdlib; the `rd` door is jetted with hardware floats in its interpreter, so a Float64 loop costs nothing visible. Two caveats decide how it is used:

- **The branch is stale.** Its base is 2026-09-09; it is 184 commits behind `master`, and its substrate still spells `Real` where master spells `Float64`. Programs written against master's prelude do not check under it. Step P0 rebases it or pins ATL to its prelude until it is rebased; the plan assumes a rebase, because the LSP and the sub-second loop are worth it.
- **Its interpreter is not NockVM.** It jets by formula identity and runs ~6M Nock steps per second. A value it produces is authoritative only once `jockc.sh` agrees. CI runs the authority lane; the inner lane never gates a merge alone.

**NockVM** has no float jets (`crates/nockvm/.../jets/hot.rs` jets integer math and bit ops only). A jetless Float64 add costs ~0.3 ms there. The REPL is usable on vectors of thousands; matrix work waits for P7.

**No Gall or `%sole` path in v1.** Jock kernels are NockApp-shaped. The 2024 Hoon tree (`desk/`, a shoe agent) was removed at v1 and stays in history at b721975. A v2 Gall host would hold the Jock-compiled compiler as a noun and fire it with raw Nock. That bridge is untyped and unbuilt; it is a §4 item.

### 1.1 Lagoon via FFI — the strategy (ruled 2026-10-27)

**Lagoon enters as a Jock `%nock` package, not as Jock source.** `pkg/lagoon-core.hoon` is a curated Hoon core of pass-through gates over the vendored Lagoon door (rounding pinned `%n`), the hoon-138 `rd` door, `/lib/math`'s `rd` door and `/lib/twoc` at 64 bits; `tools/pkg.sh` compiles it against the Jock compiler tree with `vendor/numerics` laid beside it and ships honk's construction formula as `pkgs/lagoon.jam`, which `tools/libs.py` turns into an `%nock` library and the program evaluates at startup (so `%fast` registration would fire on a jetted runtime). The package declares two struct types, `Meta` and `Ray`, whose erasure IS Lagoon's `$meta`/`$ray` cell layout, so a ray crosses the boundary untouched and Jock reads `r.meta.shape`. Battery order is signature order; new arms go at the end.

**An ATL array is a ray plus ATL's kind tag** (`src/array.jock`): 1 nat `%uint`, 2 int `%int2`, 3 real `%i754`, 4 char `%uint` codepoints, every ray bloq 6 so promotion never changes width. Lagoon owns storage, construction, reading back, and the same-meta elementwise arms; ATL owns scalar extension, the kind lattice, division-by-zero and residue's sign rule, the transcendentals (through the package's scalar doors, elementwise over the ravel), and display. The split is by semantics: an arm whose Lagoon meaning equals the APL meaning is called directly, anything with a per-element decision walks the ravel in Jock.

**Vendoring is a script**, `tools/vendor-numerics.py`, because three patches stand between the numerics checkout and honk: import-line comments, the `..part` jet parent, and the float-literal sign (S-12). A re-vendor re-applies them; `vendor/NUMERICS.txt` records the pin and the rules.

**What this buys and costs.** Lagoon's 2680 lines of tested array code and its packed layout come for free, and the vere-fork SoftBLAS jets stay reachable in principle (the `..part` patch must be undone for that build). Under NockVM nothing is jetted: `bin-op` walks the ravel with `snag` (quadratic), a Float64 op costs ~0.3 ms, and a corpus-sized program pays ~2 s of package evaluation at startup. Acceptable for the REPL; P7's inference decides what to specialize.

## 2. Repository layout (target)

```
src/
  lexer.jock       D-1..D-8    text -> tokens (UTF-8 decoded, glyph table)
  parser.jock      D-20..D-33  tokens -> AST (right-to-left, strands, operators, ∇)
  array.jock       D-10..D-15  the array model and kind lattice
  prims.jock       D-41..D-43  the primitives, as Jock funcs over arrays
  interp.jock                  the reference evaluator (closure interpreter)
  infer.jock       D-53        rank/shape/kind propagation (P7)
  (the emitter)    D-50..D-52  in interp.jock: AST -> Nockasm over [rt env], lowered by the nasm package
  repl.jock        D-54, D-60..D-62  the kernel: impl Kernel, command dispatch
tests/
  atl/*.atl        one case per file:  source, then `⍝ expect:` / `⍝ refuse:` trailer
  run.jock         the corpus runner: interpreter and emitter on every case, differential
tools/
  atlc.sh          jonk or jockc.sh behind one verb (run | check | kernel | corpus)
docs/
```

The corpus format is the Jock one: a rule without a vector is not a rule; refusal cases assert the tag.

## 3. Order of work

Dependency order. Each phase lands with its vectors; a phase's exit test is mechanical.

**P0 — Toolchain (step 1).**
jonk is PENDED (ruled 2026-10-27): its author will rebase the branch; until then the inner loop is `jockc.sh` and S-3 stays open. `tools/atlc.sh` wraps both compilers. A `tests/atl/` corpus of the README examples, expected values transcribed by hand, with a runner that reports which cases pass under which lane.
*Exit:* `atlc.sh corpus` runs under both lanes and prints a per-case table; one trivial case (`1`) passes end to end.
**LANDED 2026-10-27** on the honk lane alone: 17 cases, 81 steps in `tests/atl/`, one generated program per run (`tests/gen/corpus.jock`, ~28 s), `trivial` 1/1 and every other case 0/n against the stub in `src/atl.jock`. The product travels through `jockc.sh --diag` as an atom and is decoded as a cord: the prose renderer prints a String reached through an import as a bare number (S-9).

**P1 — Lexer.**
UTF-8 decoding (Jock strings are byte-oriented; a codepoint walker is the first thing written and the first §4 note). The glyph table transcribed from `desk/sur/atalante.hoon` (history, b721975). Numerals with `¯`, `E`, `.`; strands; character literals; `⎕` names; `)` commands; `⍝`; `⋄`. Positions in columns of glyphs, not bytes.
*Exit:* every corpus case tokenizes; refusal cases for D-3 and D-5 assert their tags.
**LANDED 2026-10-27.** `src/lexer.jock` (246 lines) over the prelude's `String.chars()` UTF-8 decoder; `tests/lex/` holds 4 cases, 30 steps (numerals, numeral refusals, names and glyphs with the D-9 aliases, character literals and system tokens), all green on the first compile; `atlc.sh lexcheck` lexes all 81 evaluation-corpus lines with 0 refusals. A lex corpus run costs ~47 s (the generated program now imports two modules).

**P2 — Parser.**
AST as a Jock union: `%array` literal, `%name`, `%monad`, `%dyad`, `%op`, `%index`, `%assign`, `%strand`, `%tradfn`, `%system`. Right-to-left with D-22 valence resolution against a store signature (names → array | function with valence). Operators per D-21. `∇` capture per D-30/D-31.
*Exit:* the green prompt (D-54) prints the AST of every README expression; SYNTAX ERROR vectors green.
**LANDED 2026-10-27.** `src/parse.jock` (~500 lines): phase A classifies tokens into items left to right under a name-class signature and folds operators into derived functions; phase B builds the tree right to left. `tests/parse/` holds 5 cases, 65 steps: every README expression, the operators, indexing, statements and headers, and 21 refusals across the syntax, value, valence and nested tags. 64/65 on the first compile; the one miss was a test whose signature left two names unbound. A parse corpus run costs ~88 s (three modules in the generated program).
The GREEN PROMPT is in `src/atl.jock`: the session threads a name-class signature that assignments and ∇ headers update, holds definition mode (D-62), and prints the tree for a `🍏>` line (D-54). `tests/atl/readme-green.atl` types EVERY README and ast.md expression at the green prompt, the Caesar block verbatim with its tab-indented body and the body expressions again at top level: 40/40, and that case at 100% is the P2 GATE on the evaluation corpus. All three lanes were re-run after the session edit: lex 30/30, parse 65/65, eval 50/121. Parse-time refusals now reach the evaluation corpus too, which moved from 1/81 to 50/121 with the stub evaluator untouched: every new pass is an assignment or definition line that prints nothing, or a VALUE, VALENCE or SYNTAX refusal the parser owns.

**P3 — Array model and scalar functions, interpreted.**
`array.jock` (D-13, over Lagoon rays per section 1.1), the kind lattice and promotion (D-11, D-12), scalar extension and the rank/length errors (D-25). All of D-41 through the closure interpreter. Display per D-45.
*Exit:* `n+4`, `2 * 10 *⍟ 10`, `5 DIV 6`'s arithmetic, all of ast.md's scalar table; three vectors per glyph.
**LANDED 2026-10-27.** `src/array.jock` (189 lines), `src/interp.jock` (~340 lines: literals, names, assignment, `⎕IO`/`⎕PP`, every monadic and dyadic function of D-41 except roll, display with ⎕PP rounding), `pkg/lagoon-core.hoon` (48 arms), `tools/pkg.sh`, `tools/vendor-numerics.py`. Evaluation corpus 78/121 (from 50/121 at P2): `power-log` 7/7 including `2.642213044E60` at ⎕PP 10, `residue-sign` 7/7, `vector-add` 5/5, `readme-green` 40/40; lex 30/30 and parse 65/65 unchanged. A corpus run is three programs of ~2.5 min each (S-13). Every remaining failure in the evaluation corpus is a structural function (D-42/D-43, P4), indexing (D-23, P4), a user-function call (P6) or `)` commands (P6).

**P4 — Structural functions and operators, interpreted.**
D-42 and D-43: `⍳ ⍴ , ⌽ ⊖ ⍉ ↑ ↓ ⍋ ⍒ ∊ / \ ⊥ ⊤ ? ⊣ ⊢`, then `f/ f⌿ f\ f⍀ f.g ∘.g f¨`. Bracket indexing and indexed assignment (D-23).
*Exit:* the README's sieve `(~R ∊ R ∘.× R) / R ← 1↓⍳R`, `X[⍋X]` on a numeric vector, `+/3+⍳4`; the whole README minus nested strings.
**LANDED 2026-10-27.** The structural functions of D-42 (`⍳ ⍴ , ⌽ ⊖ ⍉ ↑ ↓ ⍋ ⍒ ∊ / \ ⊥ ⊤ ⊣ ⊢`, with `⊥ ⊤` on naturals and `↑ ↓` on vectors), the operators of D-43 (reduce and scan on both axes, inner and outer product, each) and bracket indexing with indexed assignment (D-23), all in `src/interp.jock` over the ravel with the Lagoon ray as storage. Four cases added (`indexing`, `catenate`, `axes`, `readme-red`: the README transcript at the red prompt). The exit test's "whole README" includes the README's tradfn lines, so TRADFN CALLS landed here rather than at P6: a header opens definition mode and the session feeds body lines to the environment as SOURCE; a call unbinds the header's locals, binds the arguments, parses and runs each body line against the signature as it stands and caches the trees under that signature, so a repeat call with the same signature runs them unparsed and any class change re-parses (D-34, pinned by `atl/tradfn-cache`), reads the result, and restores every local to the caller's value or to unbound (D-31, dynamic scope); non-assignment body lines print through an output buffer the top-level statement drains. `readme-red` is the README as written, minus the nested-string example, at the red prompt, and that case at 100% is the P4 GATE. Evaluation corpus 198/198, 23/23 cases (from 78/121 at P3); lex 30/30 and parse 65/65 unchanged; a full corpus run is one program, ~3 min. Two corpus misses were test errors: APL right-aligns matrix columns (`1 3  6` over `4 9 15`), and the runner dropped the leading spaces of an expectation --- it now strips exactly one.

**P5 — The emitter.**
`emit.jock`: AST → Nock formula over `[rt store]` (D-50), primitives by axis (D-51), names by store lookup (D-52). The runtime core is the same `prims.jock` the interpreter calls. Every corpus case runs through both and the values must match; the emitter's output is also pinned noun-for-noun for a fixed subset (the emission goldens).
*Exit:* interpreter and emitter agree on the full corpus; `:nock` display works at the green prompt.
**LANDED 2026-10-27, targeting NOCKASM.** The emitter (in `src/interp.jock`, section "the emitter"; it began as `emit.jock` and moved in so a tradfn body could be emitted from inside a call) compiles a statement to a `$nasm` program (the Jock enum `Nasm` erases to the vendored IR's cell layout) over the subject `[rt env]`, where rt is `interp.runtime()`, a tuple of eleven gates named in the subject SCHEMA by `interp.gateNames()`; the program refers to every gate and to the environment by name, never by a literal axis (D-51; the expander's `#let` shifts own the axes). APL's order is kept by threading the environment through names: each intermediate result is `#let`-bound to a fresh temporary and the environment after it is bound beside it, so a left argument is emitted against the environment the right one produced. Every gate is total over `Ev`, so an error flows through and the program has no branch. Lowering and rendering go through the `nasm` package (`pkg/nasm-core.hoon`: the vendored reference expander and renderer); `eval` runs the Nock and the product is cast back to `interp.Ev`. The session runs EVERY red-prompt statement through both paths and reports `%emit-mismatch` when output or environment differ, so the whole evaluation corpus is the differential; `tests/atl/nock.atl` pins the canonical rendering of four programs at `🍏> :nock` (D-54). Evaluation corpus 239/239, 25/25 cases with every red statement run both ways and every tradfn body statement run through its formula as well (a run is one program, ~7 min with the differential); lex 30/30, parse 65/65. TRADFN BODIES ARE EMITTED TOO (D-34, literally): on a cache miss each body line is parsed, each of its statements lowered to a formula, and the cache holds the trees AND the formulas; every body statement runs through the interpreter and through its formula and the two results are held equal (`%emit-mismatch` otherwise), on a hit and on a miss alike. `tools/goldens-oracle.py` (`atlc.sh oracle`) is the INDEPENDENT check of the goldens: the rendered text of every golden program, lowered by sigilante/nockasm's Python implementation --- code this program never runs --- must equal the pinned noun (the IR's round-trip law, N-35, across two implementations): 14/14. The EMISSION GOLDENS are `tests/atl/goldens.atl`: fourteen programs across every emitted form (literal, name, niladic and monadic and dyadic user functions, system variable, monadic and dyadic primitives, a derived function, an outer product, assignment, system assignment, indexing with an elision, indexed assignment) pinned as the LOWERED NOCK NOUN at `🍏> :noun`, checked by hand against the runtime tuple's axes (`g-env` at 7167 after one `#let`, `g-dyad` at 1982 after three), plus one rendering.

**P6 — The REPL kernel.**
`impl Kernel`: poke `[%command line]`, effect `[%markdown text]`, state = store + definition-mode buffer (D-62) + `⎕IO`/`⎕PP`. Tradfn definition and call (D-30..D-33), `)VARS` and friends (D-61). Built with `kern.sh`, hosted by `jojo`. `⍎` becomes cheap here and may enter.
*Exit:* the README transcript, typed into jojo, reproduces every printed line except the nested-string ones; a kernel vector (`// kernel: N` style) pokes the sieve and peeks the store.
**LANDED 2026-10-27.** `app/kernel.jock`: `class Atl(KS) impl Kernel<nockapp.Effect>` over the session; a poke `[%command line]` (jojo's wire, which arrives wrapped in the runtime's ovum `[1 wire eny our now cause]`, S-19) goes through `atl.stepLine` and answers one `[%markdown text]` effect; `)OFF` adds `exit`; peek answers the environment. The session gained the `)` commands (`)VARS` `)FNS` `)ERASE` `)OFF`, D-61) and the prompt modes (`)GREEN` `)RED` `)TOGGLE`, D-54), pinned by `tests/atl/commands.atl` (21/21). `tools/atlc.sh kernel` builds `out/atl-kernel.jam` (unsealed, 7.5 MB); `tools/atl-repl.sh` boots it under jojo in tmux with F5/F6/F7 bound to the prompt commands; `docs/repl.md` is the guide. Two lanes pin it: `kernel-test` (the kernel vector: the sieve poked through arm 23, the store peeked through arm 22 and decoded, 5/5) and `repl-test` (the README transcript typed at the prompt, 25/25 lines, 0.3 s each, 8 s for the transcript). jojo is not slow for this kernel: boot 75 s (first boot compiles the program; later boots are checkpointed), and a README line answers in 0.3 s, both paths included. `⍎` did not enter (it stays D-44, v2); nothing in P6 needed it.

**P7 — Inference and the packed erasure.**
Budd's passes (`infer.jock`, D-53) selecting specialised primitives, pinned by the `generic == specialised` differential over the corpus. Then the Lagoon-shaped packed erasure for `%real` and `%nat` arrays, and the float arms ATL still lacks in Jock's prelude (`⌊ ⌈ ⋆ ⍟ ○ !` on Float64, float↔int, `⎕PP` formatting) as a `%nock` package over the `rd` door and `/lib/math`, built with `tools/pkg.sh` from the `chain-core.hoon` template.
*Exit:* every corpus case unchanged in value; a 1e5-element `+/` measurably faster than P5 under NockVM; the package's arms each carry a vector.
**LANDED 2026-10-27.** The packed erasure and the float package landed at P3 (section 1.1). INFERENCE is `inferK` in `src/interp.jock`: the kind and rank a value has statically, from literals, the store, D-12's result kinds and the structural functions' shapes; it is an optimisation and nothing else (D-53): the emitter uses it to CHOOSE a gate, and every specialised gate re-checks its precondition at runtime and falls back to the generic path, so a missing or wrong inference costs speed, never a value. Eight specialised gates, each used only where its result is bit-identical to the generic path, and each a LINEAR pass over the ravel in Jock with the very scalar operations the generic path uses (64-bit wrap for naturals and integers, the rd door at %n for reals): `g-reduce` (`+/ ×/ ⌈/ ⌊/` on a rank-1 numeric array, a right fold), `g-arith` (`+ − ×` on two same-kind same-shape arrays, a zip), `g-mmul` (`+.×` on naturals and integers: a dot per row and column; not reals, whose summation order would differ), `g-transpose` (rank 2, Lagoon's), `g-reshape` (equal counts: Lagoon's, a relabel), `g-iota` (Lagoon's iota shifted by ⎕IO), `g-abs` (Lagoon's, integers and reals), `g-index1` (one scalar index on a vector: Lagoon's get-item). Two findings decided that shape: the generic path reaches Lagoon's `+bin-op`, which walks the ravel with `+snag` (quadratic), and Lagoon's reductions cost ~1.6 ms per element through `+reel` against ~10 µs for a Jock fold with jetted arithmetic (S-22), so a "specialisation" through `cumsum`/`max`/`min` was slower than the generic fold and the comparisons gained nothing; those arms left the package. The corpus is the `generic == specialised` differential: every red statement still runs both ways, and 260/260, 26/26 cases. The emission goldens were re-blessed (the runtime tuple grew, so every gate past `g-env` moved) and the oracle agrees, 14/14. The BENCHMARK (`tools/bench.sh`, one jockc run per point, the per-size baseline subtracted; noise about ±3 s): at 1e5 elements the generic `+/` costs 13 s of evaluation and the generic `⌈/` 5 s, the specialised gates cost less than the noise (the micro-benchmark of the Jock fold alone: ~1 s; Lagoon's `cumsum` on the same ray: ~260 s). The setup itself, building a 1e5-element list in Jock, costs ~40 s under NockVM, which is why the baseline is per size.

The package's arms and the case that reaches each (the exit test's last clause):

| arm | reached by |
|---|---|
| `fill` `from` `ravel` | every array (`atl/vector-add`) |
| `getitem` | `g-index1` (`atl/goldens` `n[2]`, `atl/indexing`) |
| `add` `sub` `mul` | the generic `+ − ×` on same-shape rays (`atl/vector-add`, `atl/residue-sign`) |
| `abs` | `g-abs` (`atl/residue-sign` `∣¯4`) |
| `change` | natural → real promotion of a non-scalar (`atl/tradfn-div` `1 2 3 DIV 2`, `atl/power-log`) |
| `iota` | `g-iota` (`atl/reduce-scan`, `atl/sieve`) |
| `reshape` | `g-reshape` (`atl/reshape`, `atl/axes`, `atl/readme-red`) |
| `transpose` | `g-transpose` (`atl/take-drop-rotate` `⍉2 3⍴⍳6`) |
| `rsun` `rsan` `rtoi` `rsqt` `rdrg` `rexp` `rlog` `rpow` `rsin` `rcos` `rtan` `rasin` `racos` `ratan` `rpi` `rfact` | the scalar functions (`atl/power-log`, `atl/display`) |
| `tneg` `tabs` `tmsb` `ts2t` `tt2s` `rflo` `rcei` | integers, floor and ceiling (`atl/residue-sign`, `atl/power-log`) |

Removed from the package on measurement: `cumsum` `max` `min` `dot` `mmul` (S-22), `gth` `gte` `lth` `lte` `equ` `neq` (quadratic `+bin-op`, and a Jock zip is exact), `setitem` (a rebuild per element), `div` `mod` `pow-n` `prod` (S-21).

**Deferred past P7:** nested arrays or their alternative (D-6), branching or dfns (D-32), the Gall host, ASCII input (D-8), `⎕TYPE` (D-15), SoftBLAS jets (vere fork only).

## 4. The shakedown ledger

What ATL asks of Jock that nothing else has, each a finding to file once hit. Appended as found; never deleted, marked when fixed upstream.

| # | gap | where ATL hits it | status |
|---|---|---|---|
| S-1 | Float64 surface is add/sub/mul/div/compare/Show; no floor, ceiling, sqrt, exp, log, pow, trig, float↔int, or precision control | P3 (`⌊ ⌈ ⋆ ⍟ ○ !`, `⎕PP`) | open — P7 package, or prelude wrappers upstream |
| S-2 | Strings are byte-oriented; no codepoint iteration | P1 | CLOSED 2026-10-27 — the prelude already has `String.chars() -> List<UniChar>` and `utf8()` back; the lexer rides them |
| S-3 | jonk branch stale against master (`Real`/`Float64`), no PR | P0 | open |
| S-4 | No Float64 jets under NockVM (~0.3 ms per op) | P3, P7 | runtime finding, not a Jock bug |
| S-5 | A sealed kernel runs jetless; an unsealed one carries the compiler and compiles at boot | P6 | known upstream (wilt arc, 1.1) |
| S-6 | No Gall / `%sole` host; no typed bridge from a Jock func value to Hoon | v2 | open |
| S-7 | Compile time of a several-thousand-line Jock program is unmeasured | P5 onward | measure at P2 and P5 |
| S-11 | An imported module's function cannot be used as a VALUE: `let h = lagoon.tneg;` refuses `%mint-field` ("`*` has no field tneg") at top level, in a named func, and inside a lambda alike, for `%nock` packages and `%jock` modules (`let h = lexer.text;`) both; the CALL `lagoon.tneg(x)` works in every one of those positions. First reported here as a lambda limitation --- that was the shape it was met in, not the cause (five-shape repro 2026-10-27) | P3 | open upstream — worked around (named wrappers in the importing module); to file on sigilante/jock |
| S-12 | **honk** (hatch) parses a positive `@r` literal with a non-negative decimal exponent as NEGATIVE: `.~1` → `0xbff0…`, `.1`, `.~~1`, `.~1.5e2` likewise; `.~0.5`, `.~1.0e-10` and the Urbit dojo are right. Cause: `binaryfloat_mul`'s sign branch tests zero mantissas where `binaryfloat_div` tests `sa == sb` (`crates/hatch/src/utils.rs` ~4153). FIX BUILT AND VERIFIED 2026-10-27: with the one-line change, honk built from nockchain `9bcc26c6` parses all eight literal forms right and the ORIGINAL unpatched numerics sources give `factorial 5` = 120, `pow 2 10` = 1024, `gte 3 0` = true. `cargo test -p hatch` passes on the patched tree; the patch is `docs/upstream/hatch-mul-sign.patch`. The vendored sources stay rewritten to the safe form until the fix ships | P3 | open upstream — patch verified, PR not yet opened |
| S-13 | honk-kick appeared to crash untagged on the whole evaluation corpus as one program | P3 | CLOSED 2026-10-27 — misattributed: the untagged crash was `factorial`'s `?>` under the S-12 literal bug; with the vendored sources fixed the whole corpus runs as ONE program in 2:50 (198/198), which is now the runner's default (`ATL_BATCH` still splits it) |
| S-14 | `eval` is a Jock keyword, so a module cannot be named `eval.jock` and a func cannot be named `eval`; the refusal is a bare `%parse-name` at the import | P3 | open upstream — a hint naming the keyword; to file on sigilante/jock with S-11 and S-15 (the maintainer's call) |
| S-15 | `is` is a keyword, so `(i, is)` as a pattern refuses a bare `%parse-patt` with no hint naming the keyword | P4 | open upstream — same hint as S-14; to file with it |
| S-16 | A type declaration between two `func`s splits the adjacency group, and the `%mint-limb` hint says so exactly ("only ADJACENT funcs see each other --- move them together"). Not a bug: a model diagnostic | P4 | closed — praise |
| S-17 | `let` is a keyword, so an enum case cannot be named `let` and a Jock enum cannot erase to Nockasm's `[%let p q r]`; the emitter spells the case `bind` and the package rewrites the tag structurally before lowering | P5 | open upstream — a case-name escape (or a tag override) would let a Jock type target any Hoon mold; to file with S-14/S-15 |
| S-18 | A raw `%atom` as a `%cell` element lands in formula position and crashes under Nock; the emitter's list terminator must be `(%const 0)`. Not a Jock issue: the IR says so (cells are structural) and the emitter got it wrong once | P5 | closed |
| S-19 | A Jock kernel's `poke(self, e)` receives, under jojo's host, the whole runtime ovum `[1 wire eny our now cause]` rather than the bare cause the kernel examples match on (`watcher.jock` does `e as? LocalPageV0`); Jock's own REPL kernel reads `[%command @]` from the same position, so one of the two shapes is a host difference the trait does not name | P6 | open upstream — the kernel accepts both; worth a sentence in runtime.md R-90 |
| S-20 | `libs.py` treats every `*.jam` in a `--data-dir` as a package named by its stem, so a kernel jam written into `pkgs/` collided with the `atl` module; kernels now build to `out/` | P6 | closed — a placement rule, documented in docs/repl.md |
| S-21 | Lagoon's `prod` folds from the integer 1, which as `@rd`/`@rs` bits is a denormal, so the product of a real ray is wrong; `div`, `mod` and `pow-n` likewise cannot stand in for APL's `÷` (0÷0), `∣` (the sign rule) and `⋆` (exp·log rounding). The four are not exported from the package | P7 | open upstream (numerics) — `prod` should start from the kind's one |
| S-22 | Lagoon's reductions (`cumsum`, `max`, `min`, and `dot`/`mmul` through the same `+reel`/`fun-scalar` pattern) cost ~1.6 ms per element under NockVM at 1e5 elements, against ~10 µs for a Jock fold with jetted `add`/`mod`; `+bin-op` indexes the ravel with `+snag` and is quadratic. Measured 2026-10-28 (`tools/bench.sh`, the micro-benchmarks in the P7 record) | P7 | open upstream (numerics) — a linear `+bin-op` and a `+roll` over the ravel |
| S-23 | Lagoon's `+change` crashes on a rank-0 ray (shape `~`), which Lagoon never constructs itself; the promotion guards it | P7 | open upstream (numerics) — or document rank ≥ 1 |
| S-10 | `jockc.sh --diag run` crashes in its own Python serializer on an atom past 4300 decimal digits (a ~1.8 KB String product): `ValueError: Exceeds the limit ... for integer string conversion` | P1 | open — `PYTHONINTMAXSTRDIGITS=0` in the child's env works around it; upstream fix is `sys.set_int_max_str_digits(0)` in jockc.sh's serializer |
| S-9 | `jockc.sh run` renders a `String` returned by an imported module's func as a bare atom; the same literal at top level renders quoted | P0 | open — `--diag` sidesteps it |
| S-8 | Verified 2026-10-27: hand-built Nock in a Jock program calls a Jock func in the subject via `9 2 10 [6 …] 0 ax` (`eval` probe answered 42) | P5 | closed — assumption holds |
