# ATL/APL — The Dialect

**Status: v1 APPROVED (2026-10-27).** The maintainer approved Draft 1 as the v1 scope on 2026-10-27; `%box` nesting and the other §9 items are revisited for v2. Rules carry flat `D-n` ids, append-only. Each rule names the corpus vectors that pin it; `⟨none — UNPINNED⟩` marks a rule that has no vector yet. A rule without a vector is not a rule. OPEN items are decisions the maintainer has not taken.

ATL/APL is the APL that Atalante compiles. It is Budd's compiler subset (Budd 1987, *An APL Compiler*) with the additions the README examples use, and it is specified here as a *language*, independent of its host. The host is Jock; the companion [`docs/plan.md`](../plan.md) fixes the order in which this spec is implemented.

## 1. Principles

1. **Classical APL where it costs nothing.** Right-to-left evaluation, strand notation, scalar extension, `⎕IO`. A programmer who knows APL2 or Dyalog types ATL without looking anything up until they reach nested arrays.
2. **Flat, typed arrays.** An ATL array has a shape and one element kind. Nested arrays are v2 (D-6). This is what makes Budd's rank and type inference possible, and what makes the array layout Lagoon-compatible.
3. **Every primitive has a vector.** The symbol inventory in `desk/sur/atalante.hoon` is the checklist; a glyph enters the implemented language only with a positive vector, a negative vector and an error-class vector.
4. **Errors are tagged, positioned and classical.** APL's five error classes are the tags (D-40). A refusal renders like a Jock refusal: tag, column, the line with a caret.
5. **Compiled, not interpreted.** A statement becomes a Nock formula before it runs (D-50). The interpreter that exists during development is the oracle for the compiler, never the product.

## 2. Lexical structure

**D-1 · Source is UTF-8; glyphs are scalars, not bytes.** The lexer decodes codepoints. Every APL glyph in the inventory is one codepoint; `⎕IO`, `)VARS` and names are glyph sequences. ⟨`lex/names-glyphs`, `lex/strings-system`⟩

**D-2 · Names are `[A-Za-z_∆⍙][A-Za-z0-9_∆⍙¯]*`, plus the letter ranges `desk/lib/atalante.hoon` lists** (Greek, Cyrillic, Hebrew, Deseret). Names are case-sensitive. A name adjacent to a name needs whitespace; a name adjacent to a glyph does not. ⟨`lex/names-glyphs`, `lex/numeral-errors`⟩

**D-3 · Numeric literals.** `¯` (U+00AF) is the negative sign and part of the literal; `−` is the subtraction function. Forms: `12`, `¯3`, `1.5`, `.5` is refused, `1E6`, `1.5E¯3`. A literal with `.` or `E` is Float64; a literal with `¯` and no `.`/`E` is Int; otherwise Nat (D-10). ⟨`lex/numerals`, `lex/numeral-errors`⟩

**D-4 · Strands.** Two or more literals separated by spaces form one vector: `4 5 6 7`. A strand of mixed numeric kinds promotes to the join (D-11). Names do not strand in v1: `a b` is a SYNTAX ERROR, not a two-element vector (this is the nested-array question, D-6). ⟨`parse/readme`, `parse/refusals`⟩

**D-5 · Character literals.** `'abc'` is a character vector; `'a'` is a character scalar; `''` is the empty character vector; `''''` is one quote. Elements are codepoints. ⟨`lex/strings-system`⟩

**D-6 · Nested arrays are v2.** RULED 2026-10-27: v1 is flat. The README's `X ← 'sing' 'goddess' 'sing'` needs a boxed element kind; v1 refuses a strand of character vectors with `%nested-unsupported`. v2 revisits a `%box` kind (APL2 nesting) against a rank-2 character matrix idiom. Nothing in v1 may preclude either. ⟨`parse/refusals`, `parse/operators`⟩

**D-7 · Comments and separators.** `⍝` comments to end of line. `⋄` separates statements on one line. A newline ends a statement except inside a `∇` definition. ⟨`lex/names-glyphs`, `lex/strings-system`⟩

**D-8 · OPEN · ASCII transliteration.** `desk/sur/atalante.hoon`'s `ascii-map` is half-finished and ambiguous (`|` is both residue and part of `|^`). v1 reads Unicode only. An ASCII input layer, if any, is a lexer pre-pass with its own table and vectors, never a grammar change.

**D-9 · Four ASCII glyphs are canonical spellings, not transliterations.** `-` is `−`, `*` is `⋆`, `|` is `∣`, `~` is `∼`. ISO 13751 spells them in ASCII and every APL keyboard produces them; the lexer maps each to the inventory glyph and nothing else about D-8 changes. ⟨`lex/names-glyphs`⟩

## 3. Values

**D-10 · Four element kinds, one Bool convention.** `%nat` (Jock `@`), `%int` (Jock `Int`, ZigZag), `%real` (Float64), `%char` (codepoint). Booleans are `%nat` 0 and 1, as in APL; there is no separate Bool kind. ⟨`atl/vector-add`, `atl/residue-sign`, `atl/power-log`, `atl/display`⟩

**D-11 · The kind lattice is `%nat ⊂ %int ⊂ %real`; `%char` is apart.** A dyadic scalar function on two numeric kinds computes in the join. `%char` meets a numeric only at `=` and `≠`, and at `⍳` (index-of), `∊`, `⍋`, `⍒`. Anything else is a DOMAIN ERROR. ⟨`atl/residue-sign`, `atl/power-log`, `atl/errors`⟩

**D-12 · Result kinds are fixed per function, not inferred from values.** `÷`, `⍟`, `○`, `⋆` with a non-`%nat` exponent, and monadic `÷` answer `%real`. `⌊` and `⌈` on `%real` answer `%int`. Comparisons and the Booleans answer `%nat`. `−` on two `%nat` answers `%int` (never a crash on `3−5`). Everything else answers the join. This rule is what lets the inferencer type a statement without running it. ⟨`atl/power-log` (`2⋆10` → 1024), `atl/residue-sign` (`3−5` → ¯2), `atl/tradfn-div`⟩

**D-13 · An array is shape plus elements, row-major.** Shape is a list of naturals; rank is its length; a scalar has shape `~`. The abstract layout mirrors Lagoon's `$ray` field names (`shape`, `kind`, data) so that a packed erasure can replace the list-backed one without touching the primitives' contracts (plan P7). ⟨`atl/vector-add` (the layout is Lagoon's; plan section 1.1)⟩

**D-14 · `⎕IO` is 1 by default and may be set to 0 or 1.** It affects `⍳`, indexing, `⍋`, `⍒`, `⍳` (index-of), `∊`'s companion `⍸` (absent in v1), and `?`. ⟨`atl/index-origin` (assignment and the domain refusal)⟩

**D-15 · OPEN · `⎕TYPE`.** The README sets `⎕TYPE ← 'UINT8'`. Whether this names a declared storage width (Lagoon `bloq`) or a default literal kind is unruled. v1 parses and stores the assignment and ignores it with a warning.

## 4. Syntax and evaluation

**D-20 · Right-to-left; a function takes everything to its right.** `2×3+4` is 14. A dyadic function's left argument is the single array immediately to its left. Parentheses group. ⟨`parse/readme`, `parse/operators`⟩

**D-21 · Operators bind before functions and take their operand from the left.** `+/`, `+\`, `+.×`, `∘.×`, `f¨`. The derived function then follows D-20. Operands are primitive functions or user-defined functions in v1; no derived-function operands (`+/¨` is v2). ⟨`parse/readme`, `parse/operators`⟩

**D-22 · Monadic or dyadic is decided by what stands to the left.** A function with an array (or a parenthesised expression, or a name bound to an array) on its left is dyadic; otherwise monadic. A name's valence is looked up in the store at compile time (D-52). ⟨`parse/readme`, `parse/operators`, `parse/refusals`⟩

**D-23 · Bracket indexing.** `X[i]`, `M[i;j]`, `M[i;]`, `M[;j]`. Indices are arrays; the result shape is the catenation of the index shapes. An index outside `⎕IO`-based bounds is an INDEX ERROR. Indexed assignment `X[i] ← v` is v1. ⟨`parse/indexing` (parsing only)⟩

**D-24 · Assignment `←` is an expression whose value is its right side.** At the top level a statement whose last act is an assignment prints nothing. Variables are global unless localised in a `∇` header (D-31). ⟨`parse/readme`, `parse/statements`, `atl/indexing` (indexed assignment), `atl/readme-red`⟩

**D-25 · Scalar extension.** A scalar or one-element vector extends to the other argument's shape. Otherwise shapes must match exactly; a rank mismatch is a RANK ERROR, a length mismatch a LENGTH ERROR. ⟨`atl/vector-add`, `atl/errors`⟩

## 5. Functions

**D-30 · Tradfns.** `∇ R←A F B` opens a definition; a lone `∇` closes it. Headers: `∇F`, `∇F B`, `∇A F B`, each with optional `R←`. Lines between are statements. The REPL reads the body until the closing `∇` (D-62). ⟨`parse/readme`, `parse/statements`, `parse/refusals`, `atl/tradfn-div`, `atl/caesar`, `atl/readme-red`⟩

**D-31 · Locals are declared in the header after `;`.** `∇ R←A F B;T;U` makes `T` and `U` local; everything else is global (dynamic scope, as in classical APL). Arguments and the result are local. ⟨`parse/statements`, `atl/caesar` (locals restored: `A` unbound after the call), `atl/readme-red`⟩

**D-32 · OPEN · Branching.** `→` and labels are the classical control flow. v1 has none: a tradfn body is straight-line. The maintainer rules between `→` (Budd's subset has it) and dfns `{⍺ ⍵}` with guards (the modern form). Both are expressible on the v1 AST; neither is in it.

**D-33 · A user function's valence is fixed by its header and checked at the call.** Calling a dyadic function monadically is a VALENCE ERROR. ⟨`parse/refusals`⟩

**D-34 · A tradfn body is compiled on first call, not at the closing `∇`.** The definition stores the header and the body as token lines. The first call parses and emits the body against the store's signature at that moment and caches the formula keyed by that signature; a later change of class for any name the body reads (array to function, a new valence, unbound to bound) invalidates the cache and the next call recompiles. A body may therefore name a function defined after it, as in classical APL, and every executed line is still compiled Nock. A name unbound at the time of the call is a VALUE ERROR at that call. ⟨`atl/readme-green` (bodies captured unparsed), `atl/tradfn-div`, `atl/caesar` (compiled on call), `atl/tradfn-cache` (the hit, the class-change re-parse, the redefinition)⟩

## 6. Primitive inventory

The glyph list is `desk/sur/atalante.hoon`'s `+$cultivar`. This section fixes what each v1 primitive is held to and names the ones held back.

**D-40 · Error classes.** `%syntax-error`, `%value-error` (unbound name), `%valence-error`, `%rank-error`, `%length-error`, `%domain-error`, `%index-error`, `%limit-error`. A refusal carries the tag, the statement's column, and a hint. Vectors for refusals assert the tag. ⟨none — UNPINNED⟩

**D-41 · Scalar functions (v1, pervasive, scalar-extended).**
Monadic: `+` conjugate (identity), `−` negate, `×` signum, `÷` reciprocal, `⌈` ceiling, `⌊` floor, `∣` magnitude, `⋆` exponential, `⍟` natural log, `○` pi times, `!` factorial, `∼` not (Boolean domain), `?` roll.
Dyadic: `+ − × ÷ ⌈ ⌊ ∣ ⋆ ⍟ ○ !` and `< ≤ = ≥ > ≠ ∨ ∧ ⍱ ⍲`. `∣` is residue with APL's sign convention (`¯3∣5` is `¯1`). `A○B` covers the circular functions for `A ∈ ¯7..7` as in APL2. ⟨`atl/power-log`, `atl/residue-sign`, `atl/reduce-scan` (operands), `atl/errors`⟩

**D-42 · Structural functions (v1).**
`⍳B` index generator; `A⍳B` index-of; `⍴B` shape; `A⍴B` reshape (cyclic fill); `,B` ravel; `A,B` catenate on last axis; `⌽B`/`A⌽B` reverse/rotate last axis; `⊖`/`A⊖B` first axis; `⍉B` transpose (reverse axes); `A↑B` take, `A↓B` drop (negative counts from the end); `⍋B`, `⍒B` grade (stable); `A∊B` membership; `A/B` compress, `A\B` expand (Boolean left, replicate counts in v1 too); `A⊥B` decode, `A⊤B` encode; `A?B` deal; `⊣`, `⊢` left and right. ⟨`atl/reshape`, `atl/take-drop-rotate`, `atl/grade`, `atl/compress-member`, `atl/encode-decode`, `atl/catenate`, `atl/sieve`, `atl/axes`⟩

**D-43 · Operators (v1).** `f/` reduce last axis, `f⌿` first axis; `f\`, `f⍀` scan; `f.g` inner product; `∘.g` outer product; `f¨` each (over a flat array, each is the scalar map; it earns its keep in v2). Identity elements for reduce over empty come from `ast.md`'s table. ⟨`atl/reduce-scan`, `atl/outer-inner`, `atl/axes`, `atl/readme-red`⟩

**D-44 · Held back from v1, with the reason.** `⌹` matrix divide (needs Lagoon or a float linear solver); `⍎` execute (needs the compiler in the runtime, plan P6 makes it cheap); `⍕` format (monadic only, for display, D-45); `⍷` find; `⍪` table/laminate; `≡` match and depth (match is cheap, depth is nested-only); `⍉` dyadic; `⌽` with axis `[k]`. Each enters with its three vectors or stays out.

**D-45 · Display.** Vectors print space-separated on one line; a matrix prints one row per line, columns right-aligned; higher ranks print planes separated by a blank line. Numbers print with `⎕PP` 10 significant digits, exponent form past `1E10` (`2.642213044E60` as in the README). `%real` whose value is integral prints without a point. Negative numbers print with `¯`, never `-`. Character arrays print raw, without quotes. ⟨`atl/power-log`, `atl/display`, `atl/residue-sign`⟩

## 7. Compilation model

**D-50 · A statement compiles to a Nock formula over the subject `[rt env]`.** `rt` is the runtime core: the primitives as Jock function values. `env` is the session environment: the variable store, the system variables, and the user function definitions. The formula's product is the evaluation result, value and environment or a refusal. The REPL evaluates it with `eval`, prints the value per D-45, and keeps the environment. AMENDED 2026-10-27 before P5 landed: the product carries a refusal too, so the formula needs no branch; the formula is emitted as Nockasm and lowered by the reference expander. ⟨every red-prompt case, through the session differential; `atl/nock`⟩

**D-51 · Primitives are called by axis, never by name, in emitted Nock.** The emitter knows the runtime core's layout; a primitive call is `9 2 10 [6 args] 0 axis` against the subject (verified 2026-10-27 against Jock `eval`). Changing the runtime core's layout re-blesses every emission vector. ⟨`atl/nock` (`%call 2 (%edit 6 … .g-x)` by name), the P5 probe of 2026-10-27⟩

**D-52 · Names resolve at compile time against the store's shape, not its values.** A name's kind (array or function, valence) decides parsing (D-22); its value is read at run time. An unbound name in a top-level statement is a VALUE ERROR at compile time; inside a tradfn body the check is deferred to the first call (D-34). ⟨`parse/refusals`⟩

**D-53 · Inference is an optimisation, never a semantics.** Budd's rank, shape and kind propagation chooses a specialised primitive (`%add-real-vector`) over the generic one. A program's value does not depend on whether inference ran. The differential vector `generic == specialised` pins this on every example. ⟨none — UNPINNED⟩

**D-54 · The green prompt shows, the red prompt runs.** `🍏>` prints the AST (and with `:nock`, the emitted formula) without evaluating; `🍎>` evaluates. Both are the same compiler up to the last stage. ⟨`atl/readme-green` (the tree), `atl/nock` (`:nock`, the Nockasm program)⟩

## 8. The session

**D-60 · System variables.** `⎕IO` (D-14), `⎕PP` (D-45), `⎕TYPE` (D-15, OPEN). Reading one is an expression; assigning one is validated (`⎕IO ← 2` is a DOMAIN ERROR). ⟨`lex/strings-system` (lexing only), `atl/index-origin`⟩

**D-61 · System commands.** A `)` that opens a line and is followed by a name is a command token; elsewhere `)` closes a parenthesis. `)VARS` lists variables, `)FNS` lists functions, `)ERASE name`, `)OFF` ends the session. `)SAVE` is the kernel's checkpoint and needs no command; it is parsed and answers that. ⟨`lex/strings-system` (lexing only)⟩

**D-62 · A `∇` line puts the session in definition mode** until a line that is exactly `∇`. Definition-mode lines are stored, not evaluated; a syntax error in a body is reported at the closing `∇` with the body line number. ⟨`atl/readme-green`⟩

## 9. What v2 owes

Nested arrays or their ruled-out alternative (D-6); `→` or dfns (D-32); dyadic `⍉`, axis specification `[k]`, `⍎`, `⍕` dyadic, `⌹`, `⍷`, `⍪`, `≡`; derived-function operands; ASCII input (D-8); `⎕TYPE` (D-15); packed Lagoon erasure and SoftBLAS jets (plan P7).

## References

- Budd, T. *An APL Compiler*. Springer, 1988 (the 1987 technical report is the citation in `desk/lib/atalante.hoon`).
- ISO/IEC 13751:2001, Extended APL (the error classes and the scalar-function tables).
- `desk/sur/atalante.hoon` — the glyph inventory this spec implements.
- `ast.md`, `README.md` — the examples every vector set must cover.
