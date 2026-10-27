ATL/APL primitive scalar functions (Budd1987, p. 5):

| Symbol | Function | Identity |
| ------ | -------- | -------- |
| `A+B` | Addition, `%add` | 0 |
| `A−B` | Subtraction, `%sub` | 0 |
| `A×B` | Multiplication, `%mul` | 1 |
| `A÷B` | Division, `%div` | 1 |
| `A⋆B` | Exponentiation, `%pow` | 1 |
| `A∣B` | Residue (modulus), `%mod` | 0 |
| `A⍟B` | Logarithm, `%log-base` | — |
| `A○B` | Circular, `%circle` | — |
| `A∨B` | Boolean OR, `%or` | 0 |
| `A∧B` | Boolean AND, `%and` | 1 |
| `A⍱B` | Boolean NOR, `%nor` | — |
| `A⍲B` | Boolean NAND, `%nand` | — |
| `A!B` | Combinations, `%comb` | 1 |
| `⌈B` | Ceiling, `%ceiling` | $\text{min}$ |
| `⌊B` | Floor, `%floor` | $\text{max}$ |
| `A>B` | Greater than, `%gt` | — |
| `A≥B` | Greater than or equal, `%ge` | — |
| `A<B` | Less than, `%lt` | — |
| `A≤B` | Less than or equal, `%le` | — |
| `A=B` | Equal, `%eq` | 1 |
| `A≠B` | Not equal, `%ne` | 0 |


ATL/APL statements parse to the `Ast` of `src/parse.jock` (dialect D-52 to D-54).

- The green apple prompt `🍏>` prints a statement's tree in prefix form and does not evaluate it; `:nock EXPR` at it prints the Nockasm program.
- The red apple prompt `🍎>` evaluates.

These transcripts are the vectors `tests/atl/readme-green.atl` and `tests/atl/readme-red.atl`, run by `tools/atlc.sh corpus`. An assignment prints nothing; a refusal is shown by its tag, and the kernel adds the column and a hint.

```apl
🍏> 1
1

🍏> n ← 4 5 6 7
←(n, 4 5 6 7)

🍏> n
n

🍏> n+4
+(n, 4)

🍏> +/3+⍳4
+/(+(3, ⍳(4)))

🍏> 2 * 10 *⍟ 10
⋆(2, ⋆(10, ⍟(10)))

🍏> X ← 3 1 4 1 5 9 2 6
←(X, 3 1 4 1 5 9 2 6)

🍏> ⍋X
⍋(X)

🍏> X[⍋X]
X[⍋(X)]

🍏> R ← 21
←(R, 21)

🍏> (~R ∊ R ∘.× R) / R ← 1↓⍳R
/(∼(∊(R, ∘.×(R, R))), ←(R, ↓(1, ⍳(R))))

🍏> ∇ R← A DIV B
∇ R←A DIV B
R←A÷B
∇

🍏> 5 DIV 6
DIV(5, 6)

🍏> DIV 6
%valence-error

🍏> A
%value-error

🍏> A ← 5
←(A, 5)

🍏> B ← 6
←(B, 6)

🍏> R←A÷B
←(R, ÷(A, B))

🍏> ∇ E←K CAESAR P;A;S
∇ E←K CAESAR P;A;S
A←'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
S←(K⌽A),A
E←S[A⍳P]
∇

🍏> 3 CAESAR 'HELLO'
CAESAR(3, 'HELLO')

🍏> ⎕IO ← 1                 ⍝ index origin at one
←(⎕IO, 1)

🍏> ⍝

🍏> ∇ EncryptedText ← key CaesarCipher PlainText;Alphabet;ShiftedAlphabet
∇ EncryptedText←key CaesarCipher PlainText;Alphabet;ShiftedAlphabet
	Alphabet ← 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	ShiftedAlphabet ← (key ⌽ Alphabet), Alphabet
	EncryptedText ← ShiftedAlphabet[Alphabet ⍳ PlainText]
	∇

🍏> 3 CaesarCipher 'HELLO'
CaesarCipher(3, 'HELLO')

🍏> key ← 3
←(key, 3)

🍏> PlainText ← 'HELLO'
←(PlainText, 'HELLO')

🍏> Alphabet ← 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
←(Alphabet, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')

🍏> ShiftedAlphabet ← (key ⌽ Alphabet), Alphabet
←(ShiftedAlphabet, ,(⌽(key, Alphabet), Alphabet))

🍏> EncryptedText ← ShiftedAlphabet[Alphabet ⍳ PlainText]
←(EncryptedText, ShiftedAlphabet[⍳(Alphabet, PlainText)])

🍏> matrix ← 3 3 ⍴ 1 2 3 4 5 6 7 8 9
←(matrix, ⍴(3 3, 1 2 3 4 5 6 7 8 9))
```

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

🍎> matrix ← 3 3 ⍴ 1 2 3 4 5 6 7 8 9
🍎> matrix
1 2 3
4 5 6
7 8 9

🍎> ∇ R← A DIV B
R←A÷B
∇

🍎> 5 DIV 6
0.8333333333

🍎> ⎕IO ← 1                 ⍝ index origin at one
🍎> ⍝
🍎> ∇ EncryptedText ← key CaesarCipher PlainText;Alphabet;ShiftedAlphabet
	Alphabet ← 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	ShiftedAlphabet ← (key ⌽ Alphabet), Alphabet
	EncryptedText ← ShiftedAlphabet[Alphabet ⍳ PlainText]
	∇

🍎> 3 CaesarCipher 'HELLO'
KHOOR

🍎> Alphabet
%value-error
```
