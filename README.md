# ATaLante:  Golden APL

**WIP**

An implementation of APL in Urbit.  We call Atalante's idiosyncratic APL ATL/APL.

![](./logo.jpg)

Atalante (ATL for short) is a compiler, written in Jock, which ingests ATL/APL source and produces an executable Nock noun.  The dialect is specified in [`docs/spec/dialect.md`](docs/spec/dialect.md) and the order of work in [`docs/plan.md`](docs/plan.md).

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

Nested arrays (`'sing' 'goddess' 'sing'`) are v2; v1 arrays are flat (dialect D-6).  The examples above and more are pinned as cases in [`tests/atl/`](tests/atl/README.md), run by `tools/atlc.sh corpus`.
