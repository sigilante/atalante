# The Atalante REPL

The REPL is a NockApp kernel (`app/kernel.jock`) hosted by jojo and driven from tmux.

## Run it

```
tools/atlc.sh kernel        # build out/atl-kernel.jam (~3.5 min)
tools/atl-repl.sh start     # boot it under jojo in tmux session `atl` (~75 s)
tmux attach -t atl          # type at the jojo> prompt
```

`JOCK` names the Jock checkout to build with (`vendor/JOCK.txt` records the pin); `JOJO` the jojo checkout with a release build. `tools/atl-repl.sh send LINE`, `show` and `stop` drive the session from a script.

## The prompts

A line is evaluated (the red prompt) unless the session is in green mode, where a line prints its tree instead. `🍎> ` and `🍏> ` prefixes on a line choose per line; the commands choose the mode:

| command | effect |
|---|---|
| `)GREEN` | print trees (D-54); answers 🍏 |
| `)RED` | evaluate; answers 🍎 |
| `)TOGGLE` | switch; answers the new mode |
| `:nock EXPR` at the green prompt | the Nockasm program for EXPR |
| `:noun EXPR` at the green prompt | its lowered Nock formula |
| `)VARS` `)FNS` `)ERASE n…` `)OFF` | D-61 |

In the tmux session **F5** sends `)TOGGLE`, **F6** `)GREEN`, **F7** `)RED`, so one key switches between the apple prompts.

## What a line costs

Every evaluated line runs through the interpreter and through its emitted Nock, held equal; a mismatch prints `%emit-mismatch`. On this machine a README line answers in under a second (`tools/atlc.sh repl-test` types the README transcript in and times each line). The first boot of a jam compiles the kernel program under NockVM; the runtime checkpoints it, so later boots are fast.

## The two lanes that pin it

- `tools/atlc.sh kernel-test` — the kernel VECTOR: builds the kernel with `+kernel:jock` as `kern.sh` does, pokes the README's sieve through arm 23 as `[%command line]` events, and peeks the store through arm 22, decoding the peeked array (plan P6 exit test).
- `tools/atlc.sh repl-test` — the README transcript typed into the running kernel, every printed line held to `tests/atl/readme-red.atl`.
