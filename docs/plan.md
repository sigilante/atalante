# Atalante — Implementation Plan

**Status: working plan (2026-10-27).** Atalante is rebuilt in Jock as a compiler from ATL/APL to Nock. The dialect is [`docs/spec/dialect.md`](spec/dialect.md); this file fixes the toolchain, the order of work, and each phase's exit test. The 2024 Hoon tree under `desk/` is the glyph inventory and nothing more; it is not built on.

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

**No Gall or `%sole` path in v1.** Jock kernels are NockApp-shaped. The Urbit shoe agent in `desk/app/atalante.hoon` is kept as the v2 host: it would hold the Jock-compiled compiler as a noun and fire it with raw Nock. That bridge is untyped and unbuilt; it is a §4 item.

## 2. Repository layout (target)

```
src/
  lexer.jock       D-1..D-8    text -> tokens (UTF-8 decoded, glyph table)
  parser.jock      D-20..D-33  tokens -> AST (right-to-left, strands, operators, ∇)
  array.jock       D-10..D-15  the array model and kind lattice
  prims.jock       D-41..D-43  the primitives, as Jock funcs over arrays
  interp.jock                  the reference evaluator (closure interpreter)
  infer.jock       D-53        rank/shape/kind propagation (P7)
  emit.jock        D-50..D-52  AST -> Nock formula over [rt store]
  repl.jock        D-54, D-60..D-62  the kernel: impl Kernel, command dispatch
tests/
  atl/*.atl        one case per file:  source, then `⍝ expect:` / `⍝ refuse:` trailer
  run.jock         the corpus runner: interpreter and emitter on every case, differential
tools/
  atlc.sh          jonk or jockc.sh behind one verb (run | check | kernel | corpus)
desk/              the 2024 Hoon tree, frozen as inventory (sur/atalante.hoon)
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
UTF-8 decoding (Jock strings are byte-oriented; a codepoint walker is the first thing written and the first §4 note). The glyph table transcribed from `desk/sur/atalante.hoon`. Numerals with `¯`, `E`, `.`; strands; character literals; `⎕` names; `)` commands; `⍝`; `⋄`. Positions in columns of glyphs, not bytes.
*Exit:* every corpus case tokenizes; refusal cases for D-3 and D-5 assert their tags.
**LANDED 2026-10-27.** `src/lexer.jock` (246 lines) over the prelude's `String.chars()` UTF-8 decoder; `tests/lex/` holds 4 cases, 30 steps (numerals, numeral refusals, names and glyphs with the D-9 aliases, character literals and system tokens), all green on the first compile; `atlc.sh lexcheck` lexes all 81 evaluation-corpus lines with 0 refusals. A lex corpus run costs ~47 s (the generated program now imports two modules).

**P2 — Parser.**
AST as a Jock union: `%array` literal, `%name`, `%monad`, `%dyad`, `%op`, `%index`, `%assign`, `%strand`, `%tradfn`, `%system`. Right-to-left with D-22 valence resolution against a store signature (names → array | function with valence). Operators per D-21. `∇` capture per D-30/D-31.
*Exit:* the green prompt (D-54) prints the AST of every README expression; SYNTAX ERROR vectors green.

**P3 — Array model and scalar functions, interpreted.**
`array.jock` (D-13, list-backed), the kind lattice and promotion (D-11, D-12), scalar extension and the rank/length errors (D-25). All of D-41 through the closure interpreter. Display per D-45.
*Exit:* `n+4`, `2 * 10 *⍟ 10`, `5 DIV 6`'s arithmetic, all of ast.md's scalar table; three vectors per glyph.

**P4 — Structural functions and operators, interpreted.**
D-42 and D-43: `⍳ ⍴ , ⌽ ⊖ ⍉ ↑ ↓ ⍋ ⍒ ∊ / \ ⊥ ⊤ ? ⊣ ⊢`, then `f/ f⌿ f\ f⍀ f.g ∘.g f¨`. Bracket indexing and indexed assignment (D-23).
*Exit:* the README's sieve `(~R ∊ R ∘.× R) / R ← 1↓⍳R`, `X[⍋X]` on a numeric vector, `+/3+⍳4`; the whole README minus nested strings.

**P5 — The emitter.**
`emit.jock`: AST → Nock formula over `[rt store]` (D-50), primitives by axis (D-51), names by store lookup (D-52). The runtime core is the same `prims.jock` the interpreter calls. Every corpus case runs through both and the values must match; the emitter's output is also pinned noun-for-noun for a fixed subset (the emission goldens).
*Exit:* interpreter and emitter agree on the full corpus; `:nock` display works at the green prompt.

**P6 — The REPL kernel.**
`impl Kernel`: poke `[%command line]`, effect `[%markdown text]`, state = store + definition-mode buffer (D-62) + `⎕IO`/`⎕PP`. Tradfn definition and call (D-30..D-33), `)VARS` and friends (D-61). Built with `kern.sh`, hosted by `jojo`. `⍎` becomes cheap here and may enter.
*Exit:* the README transcript, typed into jojo, reproduces every printed line except the nested-string ones; a kernel vector (`// kernel: N` style) pokes the sieve and peeks the store.

**P7 — Inference and the packed erasure.**
Budd's passes (`infer.jock`, D-53) selecting specialised primitives, pinned by the `generic == specialised` differential over the corpus. Then the Lagoon-shaped packed erasure for `%real` and `%nat` arrays, and the float arms ATL still lacks in Jock's prelude (`⌊ ⌈ ⋆ ⍟ ○ !` on Float64, float↔int, `⎕PP` formatting) as a `%nock` package over the `rd` door and `/lib/math`, built with `tools/pkg.sh` from the `chain-core.hoon` template.
*Exit:* every corpus case unchanged in value; a 1e5-element `+/` measurably faster than P5 under NockVM; the package's arms each carry a vector.

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
| S-10 | `jockc.sh --diag run` crashes in its own Python serializer on an atom past 4300 decimal digits (a ~1.8 KB String product): `ValueError: Exceeds the limit ... for integer string conversion` | P1 | open — `PYTHONINTMAXSTRDIGITS=0` in the child's env works around it; upstream fix is `sys.set_int_max_str_digits(0)` in jockc.sh's serializer |
| S-9 | `jockc.sh run` renders a `String` returned by an imported module's func as a bare atom; the same literal at top level renders quoted | P0 | open — `--diag` sidesteps it |
| S-8 | Verified 2026-10-27: hand-built Nock in a Jock program calls a Jock func in the subject via `9 2 10 [6 …] 0 ax` (`eval` probe answered 42) | P5 | closed — assumption holds |
