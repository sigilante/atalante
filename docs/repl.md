# The Atalante REPL

The REPL is a NockApp kernel (`app/kernel.jock`) hosted by jojo and driven from tmux.

## Run it

```
tools/atlc.sh kernel        # build out/atl-kernel.jam (~3.5 min)
tools/atl-repl.sh start     # boot it under jojo in tmux session `atl` (~75 s)
tmux attach -t atl          # type at the 🍎> prompt
```

The jam is built locally and never shipped: unsealed, it embeds the Jock compiler and the sources (ledger S-5). `JOCK` names the Jock checkout to build with (`vendor/JOCK.txt` records the pin); `JOJO` the jojo checkout with a release build. `tools/atl-repl.sh send LINE`, `show` and `stop` drive the session from a script.

## The prompts

The prompt is the apple of the session's mode. jojo opens with `🍎> ` (its `--prompt` flag, passed by `tools/atl-repl.sh`), and after every line the kernel sends a `[%prompt text]` effect naming the mode it is now in, so `)TOGGLE` moves the prompt itself. A line is evaluated (the red prompt) unless the session is in green mode, where a line prints its tree instead. `🍎> ` and `🍏> ` prefixes on a line choose per line; the commands choose the mode:

| command | effect |
|---|---|
| `)GREEN` | print trees (D-54); answers 🍏 and the prompt turns green |
| `)RED` | evaluate; answers 🍎 and the prompt turns red |
| `)TOGGLE` | switch; answers the new mode, and the prompt follows |
| `:nock EXPR` at the green prompt | the Nockasm program for EXPR |
| `:noun EXPR` at the green prompt | its lowered Nock formula |
| `)VARS` `)FNS` `)ERASE n…` | D-61 |
| `)OFF` | answers `bye` with an exit effect; jojo exits on the effect before rendering the text, so the session simply ends |

In the tmux session **F5** sends `)TOGGLE`, **F6** `)GREEN`, **F7** `)RED`, so one key switches between the apple prompts.

## What a line costs

Every evaluated line runs through the interpreter and through its emitted Nock, held equal; a mismatch prints `%emit-mismatch`. On this machine a README line answers in under a second (`tools/atlc.sh repl-test` types the README transcript in and times each line). The first boot of a jam compiles the kernel program under NockVM; the runtime checkpoints it, so later boots are fast.

## The two lanes that pin it

- `tools/atlc.sh kernel-test` — the kernel VECTOR: builds the kernel with `+kernel:jock` as `kern.sh` does, pokes the README's sieve through arm 23 as `[%command line]` events, and peeks the store through arm 22, decoding the peeked array (plan P6 exit test).
- `tools/atlc.sh repl-test [CASE]` — a case typed into the running kernel, every printed line held to its expectations: the README transcript 25/25; `tests/atl/commands.atl` into a FRESH instance 20/21, the one being `)OFF` as above.
