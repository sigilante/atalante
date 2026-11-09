# The GNU APL suite

Atalante runs GNU APL's own testcases, rewritten into its corpus format. Every runnable step either reproduces at the prompt or fails for one of three reasons: an Atalante bug, a deliberate dialect difference, or a GNU behaviour Atalante has not ruled on. This file sorts the failures into those three groups. The cases live in `tests/gnu/` under the GPLv3; see `tests/gnu/README.md` for provenance and licence.

## Running it

`tools/gnu-import.py` rewrites GNU's `.tc` session files into `tests/gnu/*.atl`. A step Atalante cannot express stays in the file as a `⍝ skipped (why):` comment. To run the cases, start a kernel with `tools/atl-repl.sh start`, then pass each case to `tools/repl-test.py`. A crash ends the session, so the driver must restart the kernel after one.

## Results (2026-11-09)

| Lines in `tests/gnu/` | Count |
|---|---|
| Steps typed at the prompt | 2,787 |
| Function definitions typed | 29 |
| Steps and definitions skipped as inexpressible | 1,271 |
| Typed lines that reproduce GNU's output | 2,024 |
| Typed lines that differ from GNU | 792 |

The skips are mostly GNU features that sit outside Atalante's language. They are 394 system commands, 233 complex-number steps, 128 user commands, the `⎕` names other than `⎕IO` and `⎕PP` (`⎕CR` alone is 105), and the glyphs `⍨ ⍤ ⍣ ⌷ ⍸`.

The counts leave out the `)DISPLAY APL2` line that opens each case, which reproduces in all 116. Under it a box prints in APL2's layout (D-99), as GNU prints it; that took the reproducing lines from 1,862 to 2,024, and no case lost a line.

P14 (2026-11-09) added `⍬`, the set functions `∪ ∩ ∼` and n-wise reduction (D-97, D-98), and fixed the importer's echo bug (see the harness limits below). On 2026-11-07 the suite reproduced 1,772 of 2,864 typed lines; 106 of those lines were GNU's error echoes, which no longer count. The new features' own cases now fail only on display: Union 10 of 12 lines reproduce, Without 14 of 18, Zilde 3 of 5, Intersection 6 of 8, Reduce_N_wise 22 of 27 and Reduce_N_wise_with_axis 11 of 13. Every remaining failure in them is the strand display of a nested result, except two `Without` steps that use roll.

## Atalante bugs the suite found, all fixed

- **An empty array with a huge axis hung the kernel.** `⍴ 10 100000000000000 0⍴42` walked every position of the long axis inside Lagoon's `+zeros` and died out of memory. Lagoon's shape fold multiplies with a `+mul` that is unjetted inside the package. Empty shapes now skip it, and so does transpose.
- **Factorial and binomial looped on non-integers.** `3!0.05` reached `/lib/math`'s `+factorial`, which never terminates on a fraction. Non-integral reals now refuse as a DOMAIN ERROR, since they need the gamma function. Large whole arguments are bounded too.
- **Powers with huge exponents looped.** `¯1*1E20` took one step per unit of the exponent in `/lib/math`'s `+pow-n`. Whole exponents above 64 now use repeated squaring.
- **Integer overflow wrapped silently.** It is now a DOMAIN ERROR at every width (D-15, ruled 2026-11-07). The same rule covers `⌊` and `⌈` of a huge real, and negating the most negative integer.
- **A real overflowing to infinity crashed the printer.** `1E300×1E300` was stored as infinity, and printing it raised a raw kernel error. It now refuses as a DOMAIN ERROR.
- **Real residue lost its answer.** `7|1E17` gave 0 because B÷A rounds at that size. Residue is now an exact binary long division and gives 5.
- **Fixed-point format truncated big reals.** `22 0⍕2⋆70` printed 0, because rounding passed through 64 bits. It now prints 1180591620717411303424.
- **`4○` and `¯4○` overflowed early.** `4○1E155` squared its argument. A square that overflows now takes the scaled form |x|×√(1±x⁻²).
- **Disclosing an empty character vector lost its kind.** `''≡⊃⊂''` gave 0, and now gives 1.
- **A matrix radix in `⊤` and `⊥` gave silently wrong answers.** It was read as a flat vector. It now refuses as unimplemented.
- **An empty box lost its prototype.** `↑0⍴⊂1 2 3` gave 0. An empty result now keeps the prototype (D-77), so it gives `0 0 0`, and empty boxes match by prototype.
- **Errors came in a different order from GNU's (ruled 2026-11-07).** Indexing now checks rank, then domain, then range. An integer or whole real outside the axis, such as `V[¯1]` or `V[1E30]`, is an INDEX ERROR. A numeral axis that names no axis is an AXIS ERROR, a second axis on one function is a SYNTAX ERROR, and `⍎` of a line with no value is a VALUE ERROR. `⌹` takes a scalar as a 1×1 matrix, so `⌹0` is a DOMAIN ERROR.
- **The emitter disagreed with the interpreter on a transposed box.** The two paths printed the same value but stored different forms. Boxes now take the interpreter's path.

## Dialect differences, by design

- **Nested display is a setting.** Atalante prints a box as the strand that builds it (D-76), for example `(1 1) (1 2)`, unless `)DISPLAY APL2` asks for APL2's layout (D-99), which GNU prints. The suite runs under `)DISPLAY APL2`.
- **Exponent format in a column.** GNU gives every number in a column the same exponent form, as in `2.300E1 5.6E¯3`. Atalante formats each number by itself.
- **Integer overflow refuses.** GNU and APL2 promote to a real, so `9223372036854775807+1` and `!20 22` answer in floating point there. Atalante raises a DOMAIN ERROR, because a change of kind is the program's to ask for (D-15).
- **A mixed comparison goes through the real (ruled 2026-11-07).** Atalante converts an integer to a real before comparing it with one, so `9007199254740993 ≠ 9007199254740992.0` is 0. GNU compares exactly and gives 1.
- **An axis is one numeral.** Outside the scalar functions (D-96), Atalante's axis is a single numeral (D-82). GNU's computed axes, such as `,[⍳0]A`, and its axis lists on `,` and `⊃` refuse at parse time.

## GNU behaviour Atalante has not ruled on

These are the failures that need a ruling or a feature. Counts are failing steps in the latest run.

- **Selective and strand assignment.** `(⌽V)←…`, `(2↑A)←…` and `D←(A B C)←4 5 6` refuse as "cannot assign to that". About 90 steps.
- **Dyadic grade with a collating sequence.** `'ABCDE'⍋'BEAD'`, 35 steps.
- **Axis on `↑ ↓ ⊂ ⊃`, and ravel with an axis list.** About 45 steps.
- **Roll and deal.** Monadic and dyadic `?`, 13 steps.
- **`∧` and `∨` beyond Booleans.** GNU computes the LCM and the GCD, as in `2028259601 ∧ 9094863431`. 17 steps.
- **Circle codes past ±4.** The hyperbolic codes 5 to 7 and the complex codes 8 to 12.
- **Negative replicate.** `1 ¯2 1/W` inserts fills in GNU.
- **Pick through a scalar box.** `(⊂2 2)⊃M` picks one element of a matrix.
- **Multiple width and precision pairs in `⍕`.** `4 2 12 ¯5⍕R`.
- **Gamma for `!`.** GNU computes `3!0.05` and `!2.5`. Atalante refuses.
- **Complex numbers.** These are staged next, through Lagoon's `/lib/complex`.

## Known harness limits

- The harness types each line literally. Before 2026-11-07 tmux read a line that opens with `-`, such as `-/⍳4`, as an option and dropped it.
- GNU echoes a failing line under its error in its own normal form, so `3550579489682168305 +/ 1 2 3 4 5` comes back as `3550579489682168305+/1 2 3 4 5`. Before 2026-11-09 the importer took a respelled echo for a new step and typed it; some echoes were assignments that Atalante accepted. It now drops any line with a caret line under it after an error, which removed 106 steps.
- Cases share one kernel session unless one crashes, so a name defined in one case is visible in the next. GNU's files mostly start clean, and no failure in the latest run traces to a leaked name.
- Steps that use a name defined by a skipped step fail with a VALUE ERROR. The 162 unbound-name failures are mostly these cascades, from `⎕FX`, `)COPY` (GNU's `ASSERT` helper) and `⎕TF`.
