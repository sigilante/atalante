# GNU APL's testcases, rewritten for Atalante

The cases in this directory are rewritten from GNU APL's session-format testcases (`src/testcases/*.tc` in the GNU APL source tree, here taken from the Debian packaging mirror `github.com/barak/gnu-apl` at d7d8062, GNU APL 2.0+svn3894). `tools/gnu-import.py` generates them; rerun it to refresh them.

**Licence.** GNU APL is free software under the GNU General Public License, version 3 or later, and these files are derived from its testcases, so they are distributed under the GPLv3 too. The rest of Atalante is MIT. Nothing in this directory is compiled into Atalante or shipped with it. They are test data, typed into a running kernel by `tools/repl-test.py` (start one with `tools/atl-repl.sh start`).

**What the rewrite does.** Each `.tc` step, an input line and the output GNU APL printed, becomes a `🍎>` line with its `⍝ expect:` lines, or a `⍝ refuse:` when GNU APL raised an error. GNU's spellings are mapped to Atalante's (`ρ ι ◊ ϵ ⍶ ⍹` to `⍴ ⍳ ⋄ ∊ ⍺⍺ ⍵⍵`), and a `)CLEAR` starts a new case. A step Atalante cannot express is kept as a `⍝ skipped (why):` comment, so every omission is visible: complex numbers, system names other than `⎕IO` and `⎕PP`, glyphs outside Atalante's inventory, branching, `⍞`, and system and user commands.

**What a pass means.** GNU APL follows APL2, and Atalante differs from it by design in places. The clearest is nested display, which Atalante prints as the strand that builds it (D-76). A failing step is therefore one of three things: an Atalante bug, a documented dialect difference, or a GNU behaviour Atalante has not ruled on. `docs/gnu-apl-suite.md` sorts them.
