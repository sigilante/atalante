ATL/APL primitive scalar functions (Budd1987, p. 5):

| Symbol | Function | Identity |
| ------ | -------- | -------- |
| `A+B` | Addition, `%add` | 0 |
| `A−B` | Subtraction, `%sub` | 0 |
| `A×B` | Multiplication, `%mul` | 1 |
| `A÷B` | Division, `%div` | 1 |
| `A⋆B` | Exponentiation, `%pow` | 1 |
| `A∣B` | Residue (Modulus)m `%mod` | 0 |
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


ATL/APL statements should resolve to the ATL AST,
`+$apple-tree`.

- The green apple prompt `🍏>` produces the AST of the expression.
- The red apple prompt `🍎>` evaluates the expression.

```apl
🍏> 1
[%pome %scalar trait=%int fruit=1]

🍏> a ← 1
[%fork form=%assign branches=~[[%leaf name='a'] [%pome %scalar trait=%int fruit=1]]]

🍏> n ← 4 5 6 7

[%fork form=%assign branches=~[[%leaf name='n' q=~] [%apple trait=%array q=~[~[4 5 6 7]]]]]
:: this registers a value in the symbol table; APL is global by default

[%leaf name='n' q=%scalar r=[~[4] %uint 3 ~] 0x1.0706.0504]

🍏> matrix ← 3 3 ⍴ 1 2 3 4 5 6 7 8 9
[%leaf name='matrix' q=[~ p=%scalar q=~[~[1 2 3] ~[4 5 6] ~[7 8 9]]]]
[%leaf name='matrix' q=[~ p=%array q=[[~[3 3] %int2 6 ~] 0x109.0807.0605.0403.0201]]]

🍎> n
4 5 6 7

🍏> n+4
[%fork p=%add q=~[[%sym name='n'] [%val p=~ q=]]]
[%apple p=%array q=~[8 9 10 11]]

🍏> ⍳4
[%fn p=%iota q=~[[%val p=%scalar ]]]

🍏> +/3+⍳4
[%fn p=%iota q=~[[%val p=%scalar ]]]

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
` | `R←A÷B
` | `∇
🍎> 5 DIV 6
0.8333333333
```
