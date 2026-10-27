# The parse corpus

Same format as `tests/atl`, with two differences. A case may open with a signature directive, `⍝ sig: n:a DIV:d`, giving each name's class for the parser (a array, m monadic, d dyadic, b ambivalent, n niladic); every other name is unbound. The expectation is the TREE `parse.dump` renders: `f(x)` and `f(a, b)` for applications, `a[i;j]` for indexing, `←(n, v)` for assignment, `f/` `f\` `f.g` `∘.g` `f¨` for derived functions, `∇ R←A F B;L` for a header, ` ⋄ ` between statements, or a `%tag col:N hint` line for a refusal. `tools/atlc.sh parse` runs it.
