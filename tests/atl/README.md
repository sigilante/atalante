# The ATL corpus

One case per file. A case is a session transcript: input lines in order, and after an input line the output it must print, one `⍝ expect:` line per printed line. An input line followed by no `⍝ expect:` prints nothing (an assignment). `⍝ refuse: %tag` expects the line to fail with that error class (dialect D-40). Any other `⍝` line is an APL comment and is fed to the session as input.

`tools/atlc.sh corpus` runs every case and prints a table; `tools/atlc.sh run tests/atl/NAME.atl` runs one and prints the transcript. A case name is the file name without `.atl`.
