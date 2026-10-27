# Atalante v1

**Released 2026-10-28** from master. v1 is the dialect approved on 2026-10-27, [`docs/spec/dialect.md`](spec/dialect.md) rules D-1 to D-62, implemented in Jock as a compiler from ATL/APL to Nock, with a REPL that runs as a NockApp kernel.

## What v1 is

- **The dialect.** Classical flat APL: right-to-left evaluation, strands, scalar extension, `⎕IO` and `⎕PP`, the scalar functions of D-41, the structural functions of D-42, the operators of D-43 (reduce, scan, inner and outer product, each), bracket indexing and indexed assignment, tradfns with header locals, and the `)` commands of D-61.
- **The pipeline.** Lexer, signature-driven parser, tree-walking interpreter, kind and rank inference, and a Nockasm emitter with a runtime of 19 gates. Every evaluated statement runs through both the interpreter and its emitted Nock, held equal. A tradfn compiles on its first call and the formula is cached against its signature (D-34).
- **The arrays.** Lagoon rays through two Hoon packages, `pkg/lagoon-core.hoon` and `pkg/nasm-core.hoon`, loaded as `%nock` packages. Eight specialised gates take the hot paths as linear Jock passes.
- **The REPL.** `app/kernel.jock`, booted by jojo in tmux with F5, F6 and F7 bound to the prompt commands. [`docs/repl.md`](repl.md).

## Verified at the release commit

| lane | result |
|---|---|
| `tools/atlc.sh corpus` | 260 of 260 statements, 26 cases, interpreter and emitted Nock |
| `tools/atlc.sh lex` | 30 of 30 |
| `tools/atlc.sh lexcheck` | 260 of 260 corpus input lines tokenize |
| `tools/atlc.sh parse` | 65 of 65 |
| `tools/atlc.sh oracle` | 14 of 14 goldens against the Python Nockasm |
| `tools/atlc.sh kernel-test` | 5 of 5, the sieve poked through arm 23 and the store peeked through arm 22 |
| `tools/atlc.sh repl-test` | 25 of 25 README lines at the live prompt |

| measurement | value |
|---|---|
| kernel build | about 3.5 min |
| first boot | 75 s |
| a README line | 0.3 s |
| `+/` over 100,000 elements, generic | 13 s |
| `+/` over 100,000 elements, specialised | about 1 s |

## The toolchain

[`vendor/TOOLCHAIN.txt`](../vendor/TOOLCHAIN.txt) pins every piece: Jock at 47838d9, honk and kick at nockchain 8ff5367c, jojo at a44d84d, numerics at 4727063e. The release is source only. A kernel jam is not attached: an unsealed Jock kernel embeds the Jock compiler, the Hoon prelude and every module source and compiles at boot, and a sealed one runs jetless (ledger S-5), so the jam is built locally from the pins.

## Held back

Nested arrays (D-6), control flow (D-32: dfns with guards enter in v2, `→` is omitted for good), axis specification, `↑ ↓` past rank 1, `⊥ ⊤` past naturals, reductions past rank 2, `⎕TYPE` (D-15, a reserved name), an ASCII input pre-pass (D-8, deferred to the roadmap), and the primitives D-44 lists: `⌹ ⍎ ⍕ ⍷ ⍪ ≡`, dyadic `⍉`, `⌽` with axis. A Gall or `%sole` host is v2.

## Filed upstream

The shakedown ledger in [`docs/plan.md`](plan.md) §4 records every finding. Filed on 2026-10-28:

- Jock: S-11 (a module function cannot be a value), S-14, S-15, S-17 (keyword collisions without a hint), S-19 (the poke shape under jojo).
- numerics: S-21 (`prod` folds from the integer 1), S-22 (reduction and `+bin-op` cost), S-23 (`+change` on rank 0).
- honk: S-12 (the float-literal sign), with the verified patch in [`docs/upstream/`](upstream/).

Each is worked around in this tree. v1.1 drops the workarounds as the fixes land.

## Removed at v1

The 2024 Hoon tree, `desk/`, a shoe agent with a glyph inventory in `desk/sur/atalante.hoon`. It stays in history at b721975 and the spec cites it there.
