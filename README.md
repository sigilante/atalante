# ATaLante:  Golden APL

**STATUS ~2026.11.10:  The project is at v0.2 in progress, implementing dialect v1 plus P8 (dfns with guards), P9 (nested arrays), P10 (the held-back primitives and axis specification), P11 (float jets under jojo), the rest of the spec's §9 (laminate, dfn operators, `⍺←`, error guards), P12 (ASCII input and `⎕TYPE` widths), P13 (GNU APL's testcases) P14 (`⍬`, `∪ ∩ ∼` and n-wise reduction), P15 (APL2's display as a setting), P16 (roll, deal and `⎕RL`) and P17 (GCD and LCM, hyperbolic `○`, exact `⍕`), P18 (the operators `⍨ ⍣ ⍤`) and P19 (gamma, exact naturals; 2,143 of 2,930 GNU lines reproducing).**

![](./logo.jpg)

Atalante (ATL for short) is an implementation of APL in Urbit, written in Jock.  It compiles ATL/APL source to Nock and runs as a NockApp kernel.  We call Atalante's idiosyncratic APL ATL/APL.  The dialect is [`docs/spec/dialect.md`](docs/spec/dialect.md), the order of work is [`docs/plan.md`](docs/plan.md), what comes next is [`docs/roadmap.md`](docs/roadmap.md), and the v0.1 releases are in [`docs/release-v0.1.md`](docs/release-v0.1.md).

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

Dfns, with guards for control flow (D-63 to D-69):

```apl
🍎> DIV←{⍺÷⍵}
🍎> 1 2 3 DIV 2
0.5 1 1.5

🍎> FACT←{⍵≤1: 1 ⋄ ⍵×∇ ⍵-1}
🍎> FACT 5
120

🍎> {⍺+⍵}/1 2 3 4
10

🍎> SIGN←{
⍵>0: 1
⍵<0: ¯1
0
}
🍎> SIGN ¯3
¯1
```

A dfn's assignments are local to the call, `⍺` and `⍵` are its arguments, `∇` names the dfn itself, and the first statement that is not an assignment is the result.  A line whose braces do not close continues on the next line.

Nested arrays (D-70 to D-77):

```apl
🍎> X ← 'sing' 'goddess' 'sing' 'of' 'the' 'rage'
🍎> ⍋X
2 4 6 1 3 5

🍎> X[⍋X]
'goddess' 'of' 'rage' 'sing' 'sing' 'the'

🍎> 1+(1 2)(3 4)
(2 3) (4 5)

🍎> ⍴¨X
(,4) (,7) (,4) (,2) (,3) (,4)

🍎> ≡X
2

🍎> ⊃'ab' 'cd'
ab
cd
```

An element of an array may be any array.  A strand of anything but numerals builds one, `⊂` encloses and partitions, `⊃` discloses and picks, `≡` is depth and match, `≢` tally and not-match, `↑` is first, and `¨` applies a function to each element.  A nested array prints as the strand that builds it.

Axis specification and the primitives v1 held back (D-82 to D-91):

```apl
🍎> M ← 2 3⍴⍳6
🍎> +/[1]M
5 7 9

🍎> 1 2⌽[2]M
2 3 1
6 4 5

🍎> 2 1⍉M
1 4
2 5
3 6

🍎> 'an'⍷'banana'
0 1 0 1 0 0

🍎> 2⍕1.5 2.25
1.50 2.25

🍎> ⍎'+/3+⍳4'
22

🍎> 8 ¯11 ¯3⌹3 3⍴2 1 ¯1 ¯3 ¯1 2 ¯2 1 2
2 3 ¯1
```

Laminate, partition past rank 1, and dfn operators, defaults and error guards (D-92 to D-95):

```apl
🍎> 1 2 3,[0.5]4 5 6
1 2 3
4 5 6

🍎> 1 1 2⊂2 3⍴⍳6
(1 2) (,3)
(4 5) (,6)

🍎> R←{⍺⍺/⍵}
🍎> ×R 1 2 3 4
24

🍎> F←{⍺←10 ⋄ ⍺+⍵}
🍎> F 1
11

🍎> H←{5::'len' ⋄ 1 2+⍵}
🍎> H 1 2 3
len
```

APL2's layout for boxes under `)DISPLAY APL2`, as GNU APL prints them (D-99); the strand is the default:

```apl
🍎> 'TO' 'KEN' (2 6)
'TO' 'KEN' (2 6)
🍎> )DISPLAY APL2
display APL2
🍎> 'TO' 'KEN' (2 6)
 TO KEN  2 6 
```

ASCII words under `)ASCII ON`, and storage widths per kind under `⎕TYPE` (D-8, D-15):

```apl
🍎> )ASCII ON
ascii ON
🍎> 2 3 rho iota 6
1 2 3
4 5 6
🍎> )ASCII OFF
ascii OFF

🍎> ⎕TYPE←'UINT8 REAL32'
🍎> 200+55
255
🍎> 200+100
%domain-error a natural result does not fit its width (D-15)
🍎> 1÷3
0.33333334
```

`[k]` names an axis after `⌽ ⊖ , / \` and after a reduction or scan; reductions, scans, replicate, expand, reverse, rotate, take and drop work on any rank; `⍪` tables and catenates on the first axis; `⊥ ⊤` take integers and reals; `⍕` formats to fixed point; `⍎` executes a line in the current environment; `⌹` inverts, solves and fits by least squares.

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

The green prompt `🍏>` prints a line's tree instead of evaluating it, and `:nock EXPR` at it prints the Nockasm program the line compiles to.  `)TOGGLE` switches prompts, and the prompt you see is the mode you are in.

## Run it

The REPL is a NockApp kernel hosted by [jojo](https://github.com/sigilante/jojo) and driven from tmux.  [`docs/repl.md`](docs/repl.md) is the guide.  The shortest way in needs no Jock toolchain: jojo stages the built kernel as `atalante.jam` beside its Jock REPL jams, with a manifest of what the jam embeds.

```
cd jojo && cargo run --release -- --prompt '🍎> ' atalante.jam
```

From this repository, building the kernel yourself:

```
tools/atlc.sh kernel        # build out/atl-kernel.jam (~3.5 min)
tools/atl-repl.sh start     # boot it under jojo in tmux session `atl` (~75 s)
tmux attach -t atl          # type at the 🍎> prompt; F5 toggles it to 🍏> and back
```

The prompt is the mode: `🍎>` evaluates, `🍏>` prints trees, and `)TOGGLE` (F5 in the tmux session) switches.  Prerequisites for the build, each at the commit [`vendor/TOOLCHAIN.txt`](vendor/TOOLCHAIN.txt) names:

- a Jock checkout, pointed at by `JOCK`, with `honk-codex` and `honk-kick` installed;
- a jojo checkout with a release build, pointed at by `JOJO`, for the REPL;
- tmux and Python 3 for the driver and the test harnesses.

## Tests

Every case under [`tests/atl/`](tests/atl/README.md) is a session transcript: input lines and the output each must print.  The runner evaluates each statement twice, through the interpreter and through the Nock it compiles to, and holds the two equal.

```
tools/atlc.sh corpus        # 42 cases, 511 statements
tools/atlc.sh lex           # 40 lexer vectors
tools/atlc.sh parse         # 116 parser vectors
tools/atlc.sh oracle        # 14 emission goldens against an independent Nockasm
tools/atlc.sh kernel-test   # the kernel poked and peeked, 5 checks
tools/atlc.sh repl-test     # the README typed at the live prompt, 28 lines
```

## What a line costs

| step | time |
|---|---|
| build the kernel jam | about 3.5 min |
| first boot under jojo (later boots are checkpointed) | 75 s |
| a README line at the prompt | 0.3 s |
| `+/` over 100,000 naturals, both paths (the default) | 4 s |
| `+/` over 100,000 naturals, `)PATH EMIT` | 0.3 s |
| `+/1.5×v` over 100,000 elements, both paths | 31 s |
| `⍳100000` | 0.3 s |

Measured under jojo with `tools/bench-repl.py` on 2026-11-04. Jojo jets the float doors and Lagoon's `%i754` arms (P11). By default the red prompt runs every statement twice, through the interpreter and the emitted formula, and compares them. `)PATH EMIT` runs the emitted formula alone. Printing a large array is the slow step: 100,000 reals take about two minutes on either path (roadmap P11b).

## What is held back

- A nested array is a list of arrays on the Jock side, outside the specialised gates. Its structural work runs on a `%uint` index ray, so it needs no Lagoon layout of its own (P11).
- Dfns have guards and nothing else for control flow (D-32, D-63); `→` and labels are omitted for good.  A derived function with an array operand applies monadically; `1 (2 OP) 3` is held back (D-95).
- `⎕PP` stops at 17 digits, so a `REAL128` value prints fewer digits than it carries (D-15).

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
