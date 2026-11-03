# ATL/APL — The Dialect

**Status: v2 in progress (2026-11-03).** v1 is the approved Draft 1 of 2026-10-27 with the three rulings of 2026-10-28 (D-8 deferred to the §9 roadmap, D-15 and D-32 ruled). v2 opened on 2026-11-03 with P8: the maintainer approved seven items for dfns, written as D-63..D-69, and D-21, D-22, D-32, D-33, D-52 and D-62 carry the amendments. P9 the same day: the maintainer ruled D-6 for `%box`, scoped narrowly, written as D-70..D-77 with amendments to D-4, D-11, D-23, D-25, D-41..D-45. Then the rest of §9 and P10: D-78..D-91 close nesting's held-back items and the held-back primitives with axis specification. Rules carry flat `D-n` ids, append-only. Each rule names the corpus vectors that pin it; `⟨none — UNPINNED⟩` marks a rule that has no vector yet. A rule without a vector is not a rule. No rule is OPEN; DEFERRED marks a continuation on the §9 roadmap.

ATL/APL is the APL that Atalante compiles. It is Budd's compiler subset (Budd 1987, *An APL Compiler*) with the additions the README examples use, and it is specified here as a *language*, independent of its host. The host is Jock; the companion [`docs/plan.md`](../plan.md) fixes the order in which this spec is implemented.

## 1. Principles

1. **Classical APL where it costs nothing.** Right-to-left evaluation, strand notation, scalar extension, `⎕IO`. A programmer who knows APL2 or Dyalog types ATL without looking anything up until they reach nested arrays.
2. **Flat, typed arrays.** An ATL array has a shape and one element kind. A simple array is flat and Lagoon-shaped, which is what makes Budd's rank and type inference possible; a nested array is a `%box` over a list of arrays (D-6, D-70), apart from the lattice and the gates, and nothing simple pays for it.
3. **Every primitive has a vector.** The symbol inventory in the 2024 tree's `desk/sur/atalante.hoon` (history, b721975) is the checklist; a glyph enters the implemented language only with a positive vector, a negative vector and an error-class vector.
4. **Errors are tagged, positioned and classical.** APL's five error classes are the tags (D-40). A refusal renders like a Jock refusal: tag, column, the line with a caret.
5. **Compiled, not interpreted.** A statement becomes a Nock formula before it runs (D-50). The interpreter that exists during development is the oracle for the compiler, never the product.

## 2. Lexical structure

**D-1 · Source is UTF-8; glyphs are scalars, not bytes.** The lexer decodes codepoints. Every APL glyph in the inventory is one codepoint; `⎕IO`, `)VARS` and names are glyph sequences. ⟨`lex/names-glyphs`, `lex/strings-system`⟩

**D-2 · Names are `[A-Za-z_∆⍙][A-Za-z0-9_∆⍙¯]*`, plus the letter ranges the 2024 tree's `desk/lib/atalante.hoon` lists (history, b721975)** (Greek, Cyrillic, Hebrew, Deseret). Names are case-sensitive. A name adjacent to a name needs whitespace; a name adjacent to a glyph does not. ⟨`lex/names-glyphs`, `lex/numeral-errors`⟩

**D-3 · Numeric literals.** `¯` (U+00AF) is the negative sign and part of the literal; `−` is the subtraction function. Forms: `12`, `¯3`, `1.5`, `.5` is refused, `1E6`, `1.5E¯3`. A literal with `.` or `E` is Float64; a literal with `¯` and no `.`/`E` is Int; otherwise Nat (D-10). ⟨`lex/numerals`, `lex/numeral-errors`⟩

**D-4 · Strands.** Two or more literals separated by spaces form one vector: `4 5 6 7`. A strand of mixed numeric kinds promotes to the join (D-11). AMENDED 2026-11-03: any adjacent array items strand (D-71); `a b` is the two-element vector. ⟨`parse/readme`, `parse/refusals`, `parse/nested`⟩

**D-5 · Character literals.** `'abc'` is a character vector; `'a'` is a character scalar; `''` is the empty character vector; `''''` is one quote. Elements are codepoints. ⟨`lex/strings-system`⟩

**D-6 · Nested arrays.** RULED 2026-10-27: v1 is flat; the README's `X ← 'sing' 'goddess' 'sing'` needs a boxed element kind, and v1 refuses it with `%nested-unsupported`. RULED 2026-11-03: the `%box` kind, scoped narrowly, over the rank-2 character matrix idiom, because `⍋X` on the README's `X` needs element-wise comparison the idiom cannot give; the idiom stays reachable as `⊃X`. D-70..D-77 are the rules. ⟨`atl/nested`, `parse/nested`⟩

**D-7 · Comments and separators.** `⍝` comments to end of line. `⋄` separates statements on one line. A newline ends a statement except inside a `∇` definition. ⟨`lex/names-glyphs`, `lex/strings-system`⟩

**D-8 · DEFERRED 2026-10-28 · ASCII transliteration.** v1 reads Unicode only, with D-9's four ASCII spellings. An ASCII input layer is a possible continuation on the §9 roadmap: a lexer pre-pass with its own table and vectors, never a grammar change. The 2024 tree's `ascii-map` (`desk/sur/atalante.hoon`, history b721975) is the half-finished and ambiguous start (`|` is both residue and part of `|^`) that any such pass replaces.

**D-9 · Four ASCII glyphs are canonical spellings, not transliterations.** `-` is `−`, `*` is `⋆`, `|` is `∣`, `~` is `∼`. ISO 13751 spells them in ASCII and every APL keyboard produces them; the lexer maps each to the inventory glyph and nothing else about D-8 changes. ⟨`lex/names-glyphs`⟩

## 3. Values

**D-10 · Four element kinds, one Bool convention.** `%nat` (Jock `@`), `%int` (Jock `Int`, ZigZag), `%real` (Float64), `%char` (codepoint). Booleans are `%nat` 0 and 1, as in APL; there is no separate Bool kind. ⟨`atl/vector-add`, `atl/residue-sign`, `atl/power-log`, `atl/display`⟩

**D-11 · The kind lattice is `%nat ⊂ %int ⊂ %real`; `%char` is apart.** A dyadic scalar function on two numeric kinds computes in the join. `%char` meets a numeric only at `=` and `≠`, and at `⍳` (index-of), `∊`, `⍋`, `⍒`. Anything else is a DOMAIN ERROR. AMENDED 2026-11-03: `%box` (D-70) is apart from the lattice too; a scalar function reaches into it (D-72) and meets the lattice at the leaves. ⟨`atl/residue-sign`, `atl/power-log`, `atl/errors`⟩

**D-12 · Result kinds are fixed per function, not inferred from values.** `÷`, `⍟`, `○`, `⋆` with a non-`%nat` exponent, and monadic `÷` answer `%real`. `⌊` and `⌈` on `%real` answer `%int`. Comparisons and the Booleans answer `%nat`. `−` on two `%nat` answers `%int` (never a crash on `3−5`). Everything else answers the join. This rule is what lets the inferencer type a statement without running it. ⟨`atl/power-log` (`2⋆10` → 1024), `atl/residue-sign` (`3−5` → ¯2), `atl/tradfn-div`⟩

**D-13 · An array is shape plus elements, row-major.** Shape is a list of naturals; rank is its length; a scalar has shape `~`. The abstract layout mirrors Lagoon's `$ray` field names (`shape`, `kind`, data) so that a packed erasure can replace the list-backed one without touching the primitives' contracts (plan P7). ⟨`atl/vector-add` (the layout is Lagoon's; plan section 1.1)⟩

**D-14 · `⎕IO` is 1 by default and may be set to 0 or 1.** It affects `⍳`, indexing, `⍋`, `⍒`, `⍳` (index-of), `∊`'s companion `⍸` (absent in v1), and `?`. ⟨`atl/index-origin` (assignment and the domain refusal)⟩

**D-15 · RULED 2026-10-28 · `⎕TYPE` is a reserved name.** The 2024 README set `⎕TYPE ← 'UINT8'`. Whether the name declares a storage width (Lagoon `bloq`) or a default literal kind is a v2 decision, taken when the array model gains more than bloq 6. In v1 the name is reserved: it lexes and parses as a system name (D-60), and reading or assigning it refuses with `%unimplemented`. ⟨`atl/errors`⟩

### Nested arrays (P9, 2026-11-03)

**D-70 · The `%box` kind.** An element of an array may be any array: the fifth element kind, `%box`, holds one. A box has a shape like any array; its elements are arrays. Two normal forms keep every value unique: an array whose elements are all simple scalars of one class (numeric, or character) is simple, never a box; and a box scalar holding a simple scalar is that scalar (`⊂5` is `5`). A simple array of mixed characters and numbers, `1 'a' 2`, is a box of scalars. The Lagoon layout holds no box (roadmap P11): a box is the index ray of its shape over a Jock list of its elements in ravel order, and every structural function runs on that ray. ⟨`atl/nested`, `parse/nested`⟩

**D-71 · Strands (amends D-4).** Adjacent array items strand into a vector, one element per item: numerals, character literals, names, parenthesised expressions and indexed names. A numeral is one item, so `1 2 'a'` has three elements. A strand of numerals alone is D-4's simple vector; any other strand is the vector of its items' values, each enclosed, flattened by D-70 when every item is a simple scalar. A strand binds tighter than a function: `a b + c` is `(a b)+c`. An unbound name in a strand is a VALUE ERROR at its column. ⟨`parse/nested`, `atl/nested`, `parse/refusals` (an unbound name)⟩

**D-72 · Pervasion and permutation.** A scalar function (D-41) reaches into boxes: it applies element by element, D-25 at every level, and each level takes D-70's normal form; `1+(1 2)(3 4)` is `(2 3) (4 5)`. A structural function moves elements whole: `, ⌽ ⊖ ⍉ ⍴ ↑ ↓ / \` and bracket indexing permute a box as they permute a simple array, their left argument stays simple, and overtake and expand fill with the prototype (D-77). `A⍳B` and `A∊B` compare elements by match (D-73). `A,B` with a box on either side, or characters on one side and numbers on the other, catenates the elements into a box, flattened by D-70. `f/` and `f\` over a box vector fold its elements, each result enclosed; over a box of higher rank they are held back, as are `f.g` and `∘.g` over any box. ⟨`atl/nested`⟩

**D-73 · Enclose, disclose, first, pick, depth, match, enlist.** `⊂B` encloses: a simple scalar is its own enclosure, anything else becomes a box scalar. `⊃B` discloses a box whose elements are simple scalars or vectors of one class into the simple array of shape `(⍴B),L`, `L` the longest element, each padded with its fill; on a simple array it is the identity. `↑B` is the first element, disclosed (`↑'ab' 'cd'` is `'ab'`), and the prototype of an empty array. `A⊃B` picks: `A` a scalar index in `⎕IO`, or a vector of indices followed through nested boxes; the element, disclosed. `≡B` is depth: 0 for a simple scalar, 1 for a simple array, one more than the deepest element for a box. `A≡B` is match: 1 when the shapes agree and every element matches (numbers match across kinds, a character never matches a number, a box never matches a simple array), else 0. `∊B` enlists: the vector of every leaf in ravel order, a box of scalars when the leaves mix classes. Held back: `A⊂B` partition, `⊃` of a box whose elements are boxes or of rank 2 or more, `≢`. ⟨`atl/nested`⟩

**D-74 · Each (amends D-43).** `f¨B` applies `f` to each element of `B` and encloses each result; the result has `B`'s shape and takes D-70's normal form, so `⍳¨1 2 3` is `(,1) (1 2) (1 2 3)` and `{⍵×2}¨1 2 3` is still `2 4 6`. `A f¨B` pairs elements under D-25. Over a simple array a scalar function under each is the scalar map, and the v1 vectors hold. ⟨`atl/nested`, `atl/dfns`⟩

**D-75 · Order.** `⍋` and `⍒` on a box vector sort by a total order on arrays: a simple array before a box; among simple arrays, numbers before characters, then the ravels in lexicographic order with a proper prefix first, then the shapes; among boxes, the elements in lexicographic order by this same order, then the shapes. The sort is stable (D-42). The README's `⍋X` is `2 4 6 1 3 5`. ⟨`atl/nested`⟩

**D-76 · Display of a box (amends D-45).** A box prints as the strand that builds it, so its display is ATL source: a numeric scalar bare, a character scalar or vector in quotes with a quote doubled, a numeric vector in parentheses (`(1 2)`; `(,5)` for one element; `(⍳0)` for none), a box element in parentheses as a strand, a simple array of rank 2 or more as `(shape⍴ravel)`; one space between elements. A box scalar prints as `⊂` before its element. A box of rank 2 prints one row per line, a higher rank its planes separated by a blank line, with no column alignment. `X[⍋X]` prints `'goddess' 'of' 'rage' 'sing' 'sing' 'the'`, as the 2024 README did. ⟨`atl/nested`, `atl/readme-red`⟩

**D-77 · Fill.** The prototype of an array is its first element with every leaf replaced by that leaf's fill, `0` for a number and a space for a character; the prototype of an empty array is `0`. Overtake, expand and `↑` of an empty array supply it. ⟨`atl/nested`⟩

### Nesting, the rest (P9 closed, 2026-11-03)

**D-78 · Partition.** `A⊂B`: `A` a vector of non-negative integers as long as `B` (a scalar extends), `B` a vector. An element of the result starts where `A` exceeds the count before it; a 0 drops `B`'s element. `1 1 2 2⊂'abcd'` is `'ab' 'cd'`; `1 0 1⊂'abc'` is `'a' 'c'`. Rank 2 is a RANK ERROR. ⟨`atl/partition`⟩

**D-79 · Tally and not-match.** `≢B` is the length of `B`'s first axis, 1 for a scalar. `A≢B` is `∼A≡B`. ⟨`atl/tally`⟩

**D-80 · Disclose, in full (amends D-73).** `⊃B` takes elements that are scalars or all of one rank `R`; the result has shape `(⍴B),S` with `S` the per-axis maximum, each element padded at the end of each axis with its fill, a scalar placed at the origin of its cell; nested elements make a box, padded with the prototype (D-77). ⟨`atl/disclose`⟩

**D-81 · Boxes under the operators (amends D-72).** Along any axis the lines of a box fold under `f/` and `f\` as D-72 folds a vector. `∘.g` takes every pair of elements, `f.g` every row of `A` against every column of `B`, elements whole; the results take D-70's normal form. ⟨`atl/box-operators`⟩

### Axis specification and the held-back primitives (P10, 2026-11-03)

**D-82 · Axis specification `[k]`.** A numeral in `⎕IO`, in brackets after `⌽ ⊖ , / \ ⌿ ⍀` and after a derived `f/ f\ f⌿ f⍀`: `⌽[k]B` reverses along axis `k`, `A⌽[k]B` rotates, `A,[k]B` catenates, `f/[k]B` reduces, `f\[k]B` scans, `A/[k]B` replicates, `A\[k]B` expands. `k` is integral and within the rank, else an AXIS ERROR; a fractional axis (laminate) is held back, `⍪` covers the common case. ⟨`atl/axis`⟩

**D-83 · Past rank 2 (amends D-42, D-43).** Reduction, scan, replicate, expand, reverse and rotate work along the last axis, the first with `⌿ ⍀ ⊖`, or the named one, of an array of any rank. `A⌽B` takes a scalar or one count per line, an array of the shape of `B` without that axis. `A↑B` and `A↓B` take one count per leading axis of `B`; fewer counts than axes leave the trailing axes whole; a scalar `B` is treated as having that many axes of length 1. ⟨`atl/rank3`, `atl/take-drop-rotate`⟩

**D-84 · Table and first-axis catenate.** `⍪B` is `B` as a matrix: a scalar 1×1, a vector n×1, a matrix itself, a higher rank its first axis by the rest. `A⍪B` catenates on the first axis; a vector against a matrix is one row, two vectors are two rows, a scalar extends. ⟨`atl/table`⟩

**D-85 · Dyadic transpose.** `A⍉B`: `A` a vector of axes in `⎕IO`, one per axis of `B`, naming every result axis at least once; result axis `j` has the length of the shortest axis of `B` that `A` maps to it, and a repeated axis takes the diagonal. `(⍳⍴⍴B)⍉B` is `B`, `2 1⍉M` is `⍉M`, `1 1⍉M` is the diagonal. ⟨`atl/transpose`⟩

**D-86 · Decode and encode on integers and reals (amends D-42).** `A⊥B` evaluates the polynomial in the join kind of `A` and `B`, a scalar radix extending, `B` a scalar or vector. `A⊤B` encodes with floor and residue (APL2's rule), so negative and real values encode as they do there: `2 2 2⊤¯1` is `1 1 1`, `10 10⊤1.5` is `0 1.5`; `B` a scalar gives a vector, a vector gives a `(⍴A),(⍴B)` matrix; a 0 radix takes what remains. ⟨`atl/encode-decode`⟩

**D-87 · Find.** `A⍷B` is a Boolean of `B`'s shape, 1 where a copy of `A` begins, elements compared by match (D-73); `A` of rank at most that of `B`, both at most rank 2; a scalar `A` is `A=B` by match. ⟨`atl/find`⟩

**D-88 · Format.** `⍕B` is `B`'s display (D-45, D-76) as a character array: a vector for rank at most 1 and for a box of rank at most 1, a matrix for rank 2, one row per line of the display; a character array is itself. `D⍕B` prints each number with `D` decimals in fixed point, columns right-aligned to the widest; `W D⍕B` gives each column width `W`, and a number that does not fit is a DOMAIN ERROR. Negatives carry `¯`. ⟨`atl/format`⟩

**D-89 · Execute.** `⍎B` runs the character vector `B` as a line in the current environment, through the compiler, and is the line's value; its assignments persist. A line without a value (a system command, a `∇` header, nothing) is a DOMAIN ERROR; a refusal in the line is the refusal. ⟨`atl/execute`⟩

**D-90 · Matrix divide.** `⌹B` inverts a square matrix. `A⌹B` solves `B X = A` for square `B` and gives the least-squares solution when `B` has more rows than columns (through the normal equations); `A` a vector is one column, a matrix several. Gaussian elimination with partial pivoting over reals; the result is `%real`; a singular `B` is a DOMAIN ERROR. ⟨`atl/solve`⟩

**D-91 · Dfn operands (amends D-63).** The operand of `.` and `∘.` may be a dfn: `∘.{⍺×⍵}`, `+.{⍺×⍵}`. ⟨`atl/dfn-operands`, `parse/operators`⟩

## 4. Syntax and evaluation

**D-20 · Right-to-left; a function takes everything to its right.** `2×3+4` is 14. A dyadic function's left argument is the single array immediately to its left. Parentheses group. ⟨`parse/readme`, `parse/operators`⟩

**D-21 · Operators bind before functions and take their operand from the left.** `+/`, `+\`, `+.×`, `∘.×`, `f¨`. The derived function then follows D-20. Operands are primitive functions, user-defined functions and dfns (D-63: `{⍺+⍵}/1 2 3`); no derived-function operands (`+/¨` is on the roadmap). ⟨`parse/readme`, `parse/operators`, `parse/dfns`⟩

**D-22 · Monadic or dyadic is decided by what stands to the left.** A function with an array (or a parenthesised expression, or a name bound to an array) on its left is dyadic; otherwise monadic. A name's valence is looked up in the store at compile time (D-52); a dfn, and a name bound to one, is ambivalent (D-64, D-67). ⟨`parse/readme`, `parse/operators`, `parse/refusals`, `parse/dfns`⟩

**D-23 · Bracket indexing.** `X[i]`, `M[i;j]`, `M[i;]`, `M[;j]`. Indices are arrays; the result shape is the catenation of the index shapes. An index outside `⎕IO`-based bounds is an INDEX ERROR. Indexed assignment `X[i] ← v` is v1. AMENDED 2026-11-03: on a box the elements move whole (D-72), so `X[⍋X]` on the README's `X` is the sorted strand; an indexed assignment whose value or target is a box, or that puts characters among numbers, leaves a box. ⟨`parse/indexing` (parsing only), `atl/nested`⟩

**D-24 · Assignment `←` is an expression whose value is its right side.** At the top level a statement whose last act is an assignment prints nothing. Variables are global unless localised in a `∇` header (D-31). ⟨`parse/readme`, `parse/statements`, `atl/indexing` (indexed assignment), `atl/readme-red`⟩

**D-25 · Scalar extension.** A scalar or one-element vector extends to the other argument's shape. Otherwise shapes must match exactly; a rank mismatch is a RANK ERROR, a length mismatch a LENGTH ERROR. AMENDED 2026-11-03: a box scalar extends like any scalar, and the rule applies again inside each pair of elements (D-72). ⟨`atl/vector-add`, `atl/errors`, `atl/nested`⟩

## 5. Functions

**D-30 · Tradfns.** `∇ R←A F B` opens a definition; a lone `∇` closes it. Headers: `∇F`, `∇F B`, `∇A F B`, each with optional `R←`. Lines between are statements. The REPL reads the body until the closing `∇` (D-62). ⟨`parse/readme`, `parse/statements`, `parse/refusals`, `atl/tradfn-div`, `atl/caesar`, `atl/readme-red`⟩

**D-31 · Locals are declared in the header after `;`.** `∇ R←A F B;T;U` makes `T` and `U` local; everything else is global (dynamic scope, as in classical APL). Arguments and the result are local. ⟨`parse/statements`, `atl/caesar` (locals restored: `A` unbound after the call), `atl/readme-red`⟩

**D-32 · RULED 2026-10-28 · Control flow is dfns with guards, in v2.** v1 has none: a tradfn body is straight-line. v2 adds dfns `{⍺ ⍵}` with guards `cond: expr`, the modern form; `→` and labels, Budd's classical form, are omitted for good. Guards compose with the emitter's straight-line formulas where `→` would need a label table and a loop in the generated Nock. Both were expressible on the v1 AST; dfns are what enters. LANDED 2026-11-03 as P8: D-63..D-69.

**D-33 · A user function's valence is fixed by its header and checked at the call.** Calling a dyadic function monadically is a VALENCE ERROR. A dfn has no header: its valence is settled at each call (D-67). ⟨`parse/refusals`⟩

**D-34 · A tradfn body is compiled on first call, not at the closing `∇`.** The definition stores the header and the body as token lines. The first call parses and emits the body against the store's signature at that moment and caches the formula keyed by that signature; a later change of class for any name the body reads (array to function, a new valence, unbound to bound) invalidates the cache and the next call recompiles. A body may therefore name a function defined after it, as in classical APL, and every executed line is still compiled Nock. A name unbound at the time of the call is a VALUE ERROR at that call. A dfn body is compiled the same way (D-67). ⟨`atl/readme-green` (bodies captured unparsed), `atl/tradfn-div`, `atl/caesar` (compiled on call), `atl/tradfn-cache` (the hit, the class-change re-parse, the redefinition; the cache holds the formulas, and every body statement runs through its formula against the tree evaluation)⟩

### Dfns (P8, 2026-11-03)

**D-63 · Dfns.** `{…}` is a function value: the body between the braces is statements separated by `⋄` or by line ends (D-69). `⍵` names the right argument and `⍺` the left; `∇` inside the body names the dfn itself. A dfn stands wherever a function stands: applied to the array on its right, with an array on its left, and as the operand of `/ \ ⌿ ⍀ ¨` (`{⍺+⍵}/1 2 3`). Dfns nest. Out of v2, on the roadmap: dfn operators (`⍺⍺ ⍵⍵`), a default left argument (`⍺←`), error guards (`::`), and a dfn as the operand of `.` or `∘.`. ⟨`lex/dfns`, `parse/dfns`, `atl/dfns`⟩

**D-64 · A name takes a dfn by assignment and is then an ambivalent function.** `F←{⍺÷⍵}` binds `F` with class ambivalent (D-22, D-52): `F 6` is monadic, `5 F 6` dyadic. Only a brace literal is assigned as a function; `F←+` is a SYNTAX ERROR. The name is one name: an array assigned to it later makes it an array (`DIV←3`), a `∇` definition replaces the dfn, and a dfn assignment replaces a tradfn. `)FNS` lists it and `)ERASE` erases it. ⟨`parse/dfns`, `atl/dfns`⟩

**D-65 · Dfn scope is lexical.** A call opens a frame. An assignment in the body binds a local of that call, never a global; a read falls through the frame, then the frames of the enclosing dfns, then the store. `⍺` and `⍵` belong to the innermost dfn alone. A global dfn runs over the store, not over its caller's locals: with `a←1`, `K←{a+⍵}` and `L←{a←100 ⋄ K ⍵}`, `L 1` is 2. `⎕IO` and `⎕PP` assigned in a body are local to the call. A tradfn keeps D-31's dynamic scope and sees no dfn frame. ⟨`atl/dfns` (`H 5` then `a`; the nested read; `L 1`; `⎕IO`)⟩

**D-66 · The result is the first statement that is not an assignment; a guard chooses.** Statements run in order. An assignment, of an array or of a dfn, continues. A guard `cond: expr` evaluates `cond`, which must be a scalar 0 or 1 (DOMAIN ERROR otherwise); at 1 the value of `expr` is the result, at 0 the next statement runs. Any other statement's value is the result. A body that runs off its end has no result: VALUE ERROR. A guard outside a dfn is a SYNTAX ERROR. ⟨`parse/dfns`, `atl/dfns`, `atl/dfn-lines`⟩

**D-67 · A dfn is ambivalent; valence is settled at the call, and the body is compiled on first call (D-34).** `⍺` in a body called monadically is a VALUE ERROR at that call. The body is kept as source lines and parsed, emitted and run on the call: each line against the signature as it stands, each statement through its formula against the tree evaluation. The entry signature carries `⍺` only when bound, so monadic and dyadic calls compile apart. A named dfn caches the lines a call reached, keyed by the entry signature; a later call that goes past a false guard parses the lines beyond and extends the cache. Guards and the statement order belong to the body runner, as a tradfn's line order does: a guard's condition and its expression are each a formula, the branch between them is not Nock. ⟨`atl/dfns` (`{⍺} 3`), `atl/dfn-lines` (`SIGN`: the cache extended past its guards)⟩

**D-68 · Class changes inside a line thread the signature.** Each `⋄`-separated statement parses against the signature the statements before it leave: an assignment binds an array, a dfn assignment an ambivalent function, a header its valence. `G←{⍵+1} ⋄ G 3` is 4 with `G` an array before the line. Inside a body each line parses against the signature the lines before it left at run time, the same rule with values in hand. ⟨`parse/dfns` (`G←{⍵} ⋄ G 3`), `atl/dfns`⟩

## 6. Primitive inventory

The glyph list is `+$cultivar` in the 2024 tree's `desk/sur/atalante.hoon` (history, b721975). This section fixes what each v1 primitive is held to and names the ones held back.

**D-40 · Error classes.** `%syntax-error`, `%value-error` (unbound name), `%valence-error`, `%rank-error`, `%length-error`, `%domain-error`, `%index-error`, `%limit-error`. A refusal carries the tag, the statement's column, and a hint. Vectors for refusals assert the tag. ⟨`atl/errors` (six classes asserted by `⍝ refuse:`), `lex/numeral-errors`, `parse/refusals`⟩

**D-41 · Scalar functions (v1, pervasive, scalar-extended).**
Monadic: `+` conjugate (identity), `−` negate, `×` signum, `÷` reciprocal, `⌈` ceiling, `⌊` floor, `∣` magnitude, `⋆` exponential, `⍟` natural log, `○` pi times, `!` factorial, `∼` not (Boolean domain), `?` roll.
Dyadic: `+ − × ÷ ⌈ ⌊ ∣ ⋆ ⍟ ○ !` and `< ≤ = ≥ > ≠ ∨ ∧ ⍱ ⍲`. `∣` is residue with APL's sign convention (`¯3∣5` is `¯1`). `A○B` covers the circular functions for `A ∈ ¯7..7` as in APL2. ⟨`atl/power-log`, `atl/residue-sign`, `atl/reduce-scan` (operands), `atl/errors`⟩

**D-42 · Structural functions (v1).**
`⍳B` index generator; `A⍳B` index-of; `⍴B` shape; `A⍴B` reshape (cyclic fill); `,B` ravel; `A,B` catenate on last axis; `⌽B`/`A⌽B` reverse/rotate last axis; `⊖`/`A⊖B` first axis; `⍉B` transpose (reverse axes); `A↑B` take, `A↓B` drop (negative counts from the end); `⍋B`, `⍒B` grade (stable); `A∊B` membership; `A/B` compress, `A\B` expand (Boolean left, replicate counts in v1 too); `A⊥B` decode, `A⊤B` encode; `A?B` deal; `⊣`, `⊢` left and right. ⟨`atl/reshape`, `atl/take-drop-rotate`, `atl/grade`, `atl/compress-member`, `atl/encode-decode`, `atl/catenate`, `atl/sieve`, `atl/axes`⟩

**D-43 · Operators (v1).** `f/` reduce last axis, `f⌿` first axis; `f\`, `f⍀` scan; `f.g` inner product; `∘.g` outer product; `f¨` each (over a flat array, each is the scalar map; AMENDED 2026-11-03: over a box, D-74). Identity elements for reduce over empty come from `ast.md`'s table. ⟨`atl/reduce-scan`, `atl/outer-inner`, `atl/axes`, `atl/readme-red`⟩

**D-44 · Held back from v1, with the reason.** `⌹` matrix divide (needs Lagoon or a float linear solver); `⍎` execute (needs the compiler in the runtime, plan P6 makes it cheap); `⍕` format (monadic only, for display, D-45); `⍷` find; `⍪` table/laminate; `≡` match and depth (ENTERED 2026-11-03 as D-73); `⍉` dyadic; `⌽` with axis `[k]`. Each enters with its three vectors or stays out. ENTERED 2026-11-03 as P10: all of them, D-82..D-90, each with its vectors.

**D-45 · Display.** Vectors print space-separated on one line; a matrix prints one row per line, columns right-aligned; higher ranks print planes separated by a blank line. Numbers print with `⎕PP` 10 significant digits, exponent form past `1E10` (`2.642213044E60` as in the README). `%real` whose value is integral prints without a point. Negative numbers print with `¯`, never `-`. Character arrays print raw, without quotes. AMENDED 2026-11-03: a box prints as its strand (D-76). ⟨`atl/power-log`, `atl/display`, `atl/residue-sign`⟩

## 7. Compilation model

**D-50 · A statement compiles to a Nock formula over the subject `[rt env]`.** `rt` is the runtime core: the primitives as Jock function values. `env` is the session environment: the variable store, the system variables, and the user function definitions. The formula's product is the evaluation result, value and environment or a refusal. The REPL evaluates it with `eval`, prints the value per D-45, and keeps the environment. AMENDED 2026-10-27 before P5 landed: the product carries a refusal too, so the formula needs no branch; the formula is emitted as Nockasm and lowered by the reference expander. ⟨every red-prompt case, through the session differential; `atl/nock`⟩

**D-51 · Primitives are called by axis, never by name, in emitted Nock.** The emitter knows the runtime core's layout; a primitive call is `9 2 10 [6 args] 0 axis` against the subject (verified 2026-10-27 against Jock `eval`). Changing the runtime core's layout re-blesses every emission vector. ⟨`atl/nock` (`%call 2 (%edit 6 … .g-x)` by name), `atl/goldens` (the lowered nouns), the P5 probe of 2026-10-27⟩

**D-52 · Names resolve at compile time against the store's shape, not its values.** A name's kind (array or function, valence) decides parsing (D-22), and the statements of one line thread it (D-68); its value is read at run time. An unbound name in a top-level statement is a VALUE ERROR at compile time; inside a tradfn body the check is deferred to the first call (D-34). ⟨`parse/refusals`⟩

**D-53 · Inference is an optimisation, never a semantics.** Budd's rank, shape and kind propagation chooses a specialised primitive (`%add-real-vector`) over the generic one. A program's value does not depend on whether inference ran. The differential vector `generic == specialised` pins this on every example. ⟨the evaluation corpus, every red statement both ways; `atl/goldens` (`+/n` chooses `g-reduce`, `n[2]` chooses `g-index1`)⟩

**D-54 · The green prompt shows, the red prompt runs.** `🍏>` prints the AST (and with `:nock`, the emitted formula) without evaluating; `🍎>` evaluates. Both are the same compiler up to the last stage. ⟨`atl/readme-green` (the tree), `atl/nock` (`:nock`, the Nockasm program), `atl/goldens` (`:noun`), `atl/commands` (the modes)⟩

## 8. The session

**D-60 · System variables.** `⎕IO` (D-14), `⎕PP` (D-45), `⎕TYPE` (D-15, reserved). Reading one is an expression; assigning one is validated (`⎕IO ← 2` is a DOMAIN ERROR). ⟨`lex/strings-system` (lexing only), `atl/index-origin`⟩

**D-61 · System commands.** `)GREEN`, `)RED` and `)TOGGLE` choose the prompt mode (D-54) for the lines that follow (added 2026-10-27 for the REPL). A `)` that opens a line and is followed by a name is a command token; elsewhere `)` closes a parenthesis. `)VARS` lists variables, `)FNS` lists functions, `)ERASE name`, `)OFF` ends the session. `)SAVE` is the kernel's checkpoint and needs no command; it is parsed and answers that. ⟨`lex/strings-system`, `atl/commands`, `kernel/sieve` (`)VARS` through the kernel)⟩

**D-62 · A `∇` line puts the session in definition mode** until a line that is exactly `∇`. Definition-mode lines are stored, not evaluated; a syntax error in a body is reported at the closing `∇` with the body line number. ⟨`atl/readme-green`⟩

**D-69 · A line whose braces do not close continues on the next line** until they do; the lines are one statement, and a line end inside the braces separates statements like `⋄`. The held lines print nothing. A host that reads an open brace to its close itself (jojo does) hands the kernel the lines as one entry with line ends in it, and the lexer reads a line end as that separator; the session does the same for lines that arrive one at a time, as a transcript's do. A `⍝` comment ends at the line end. A lexing refusal in a continuation line is reported at once and the whole is dropped; a parse refusal is reported when the braces close; a body line's refusal names its line, at the call (D-67). The mode of the first line (D-54) is the mode of the statement. ⟨`atl/dfn-lines` (`SIGN`, `CAESAR`, the green `FACT`)⟩

## 9. What v2 owes

Ordered as phases P8 onward in [`docs/roadmap.md`](../roadmap.md).

A `%box` Lagoon layout (roadmap P11); a fractional axis (laminate by `[k]`, D-82); partition of rank 2 (D-78); `⍕` of rank 3 and above (D-88); dfn operators, `⍺←` and `::` (D-63); an ASCII input pre-pass (D-8, deferred); `⎕TYPE`'s meaning (D-15, the name is reserved); packed Lagoon erasure and SoftBLAS jets (plan P7).

## References

- Budd, T. *An APL Compiler*. Springer, 1988 (the 1987 technical report is the citation in the 2024 tree's `desk/lib/atalante.hoon`).
- ISO/IEC 13751:2001, Extended APL (the error classes and the scalar-function tables).
- `desk/sur/atalante.hoon` at b721975 — the glyph inventory this spec implements; the 2024 tree was removed at v1.
- `ast.md`, `README.md` — the examples every vector set must cover.
