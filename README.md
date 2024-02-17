# ATaLante:  Golden APL

**WIP**

An implementation of APL in Urbit.  We call Atalante's idiosyncratic APL ATL/APL.

![](./logo.jpg)

Atalante (ATL for short) is a Hoon compiler which ingests a source ATL/APL file and produces an executable Nock noun.

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

🍎> X ← 'sing' 'goddess' 'sing' 'of' 'the' 'rage'

🍎> ⍋X
2 4 6 1 3 5

🍎> X[⍋X]
'goddess' 'of' 'rage' 'sing' 'sing' 'the'

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
⎕TYPE ← 'UINT8'         ⍝ 8-bit unsigned integers
⍝
∇EncryptedText ← CaesarCipher key PlainText
	Alphabet ← 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	ShiftedAlphabet ← (key ⌽ Alphabet), Alphabet
	EncryptedText ← ShiftedAlphabet[(Alphabet ⍳ PlainText) + 1]
	∇
```

Use this as:

```apl
CaesarCipher 3 'Hello'
```
