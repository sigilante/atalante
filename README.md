# ATaLante:  Golden APL

**STATUS ~2026.10.28:  The project is at v1.**

![](./logo.jpg)

Atalante (ATL for short) is an implementation of APL in Urbit, written in Jock.  It compiles ATL/APL source to Nock and runs as a NockApp kernel.  We call Atalante's idiosyncratic APL ATL/APL.  The dialect is [`docs/spec/dialect.md`](docs/spec/dialect.md), the order of work is [`docs/plan.md`](docs/plan.md), and the v1 release is [`docs/release-v1.md`](docs/release-v1.md).

At the apple prompt:

```apl
🍎> n ← 4 5 6 7

🍎> n
4 5 6 7

🍎> n+4
8 9 10 11

🍎> +/3+⍳4
22

🍎> 2 * 10 *⍟ 10
2.642213044E60

🍎> X ← 3 1 4 1 5 9 2 6

🍎> ⍋X
2 4 7 1 3 5 8 6

🍎> X[⍋X]
1 1 2 3 4 5 6 9

🍎> R ← 21
🍎> (~R ∊ R ∘.× R) / R ← 1↓⍳R
2 3 5 7 11 13 17 19

🍎> ∇ R← A DIV B
	R←A÷B
	∇
🍎> 5 DIV 6
0.8333333333
```

From an input file (the Caesar cipher):

```apl
⎕IO ← 1                 ⍝ index origin at one
⍝
∇ EncryptedText ← key CaesarCipher PlainText;Alphabet;ShiftedAlphabet
	Alphabet ← 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	ShiftedAlphabet ← (key ⌽ Alphabet), Alphabet
	EncryptedText ← ShiftedAlphabet[Alphabet ⍳ PlainText]
	∇
```

Use this as:

```apl
3 CaesarCipher 'HELLO'
KHOOR
```

The green prompt `🍏>` prints a line's tree instead of evaluating it, and `:nock EXPR` at it prints the Nockasm program the line compiles to.  `)TOGGLE` switches prompts.

## Run it

The REPL is a NockApp kernel hosted by jojo and driven from tmux.  [`docs/repl.md`](docs/repl.md) is the guide.

```
tools/atlc.sh kernel        # build out/atl-kernel.jam (~3.5 min)
tools/atl-repl.sh start     # boot it under jojo in tmux session `atl` (~75 s)
tmux attach -t atl          # type at the prompt; F5 toggles the apple prompts
```

Prerequisites, each at the commit [`vendor/TOOLCHAIN.txt`](vendor/TOOLCHAIN.txt) names:

- a Jock checkout, pointed at by `JOCK`, with `honk-codex` and `honk-kick` installed;
- a jojo checkout with a release build, pointed at by `JOJO`, for the REPL;
- tmux and Python 3 for the driver and the test harnesses.

## Tests

Every case under [`tests/atl/`](tests/atl/README.md) is a session transcript: input lines and the output each must print.  The runner evaluates each statement twice, through the interpreter and through the Nock it compiles to, and holds the two equal.

```
tools/atlc.sh corpus        # 26 cases, 262 statements
tools/atlc.sh lex           # 30 lexer vectors
tools/atlc.sh parse         # 65 parser vectors
tools/atlc.sh oracle        # 14 emission goldens against an independent Nockasm
tools/atlc.sh kernel-test   # the kernel poked and peeked, 5 checks
tools/atlc.sh repl-test     # the README typed at the live prompt, 25 lines
```

## What a line costs

| step | time |
|---|---|
| build the kernel jam | about 3.5 min |
| first boot under jojo (later boots are checkpointed) | 75 s |
| a README line at the prompt | 0.3 s |
| `+/` over 100,000 elements, generic path | 13 s |
| `+/` over 100,000 elements, specialised gate | about 1 s |

NockVM jets integer arithmetic and nothing on floats, so real-valued work costs about 0.3 ms an operation.

## What v1 holds back

- Arrays are flat (D-6).  Nested arrays such as `'sing' 'goddess' 'sing'` are v2.
- A tradfn body is straight-line (D-32).  v2 adds dfns with guards; `→` and labels are omitted for good.
- No axis specification; `↑` and `↓` on rank at most 1; `⊥` and `⊤` on naturals; reductions and scans on rank at most 2.
- Held back with reasons in D-44: `⌹ ⍎ ⍕ ⍷ ⍪ ≡`, dyadic `⍉`, `⌽` with axis.
- Input is Unicode; the ASCII spellings `- * | ~` are canonical (D-9) and nothing else is transliterated (D-8).
- `⎕TYPE` is a reserved name (D-15): it parses, and reading or assigning it refuses with `%unimplemented`.

## Layout

```
src/        lexer.jock, parse.jock, array.jock, interp.jock, atl.jock: the compiler and session
app/        kernel.jock: the NockApp kernel
pkg/        lagoon-core.hoon, nasm-core.hoon: the two Hoon packages, built by tools/pkg.sh
vendor/     the pinned numerics sources and the toolchain pins
tests/      the corpus, the lexer and parser vectors, the kernel vector
tools/      atlc.sh and the harnesses behind its verbs
docs/       the dialect, the plan with its shakedown ledger, the REPL guide, the release notes
```

MIT licensed.
