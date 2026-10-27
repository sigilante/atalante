# The lex corpus

Same file format as `tests/atl` (one input line, then its `⍝ expect:` line), but the expectation is the TOKEN STREAM `lexer.dump` renders: space-separated `kind:text` words, bare kind names for punctuation, or a `%syntax-error col:N hint` line for a refusal. `tools/atlc.sh lex` runs it.
