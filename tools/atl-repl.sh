#!/bin/zsh
#  tools/atl-repl.sh:  the Atalante REPL in a tmux session, hosted by jojo.
#
#    atl-repl.sh start      boot out/atl-kernel.jam under jojo in tmux session `atl`
#    atl-repl.sh send LINE  type LINE at the prompt
#    atl-repl.sh show       the last screen
#    atl-repl.sh stop       kill the session
#
#  The prompt is the apple of the session's mode: jojo opens with
#  `🍎> ` (--prompt) and the kernel's [%prompt text] effect moves it.
#  Key bindings in the session:  F5 sends )TOGGLE (switch between the
#  green and the red prompt), F6 sends )GREEN, F7 sends )RED.
#  Env:  JOJO (default ~/Code/zorp/jojo), the jojo checkout with a
#  release build;  SESSION (default atl);  JAM (default
#  out/atl-kernel.jam; a copy under another stem is another instance,
#  which is how a test boots beside a live session without racing its
#  checkpoint).
set -e
ROOT="${0:A:h:h}"
JOJO=${JOJO:-$HOME/Code/zorp/jojo}
SESSION=${SESSION:-atl}
JAM=${JAM:-$ROOT/out/atl-kernel.jam}
case "$1" in
  start)
    [[ -r "$JAM" ]] || { echo "atl-repl: no $JAM --- run tools/atlc.sh kernel" >&2; exit 2; }
    #  RUST_LOG=warn:  the runtime's INFO lines (jet registration for the
    #  vendored numerics, which carry ~/ hints no NockVM jet matches) would
    #  otherwise interleave with the kernel's answers
    tmux new-session -d -s "$SESSION" -x 120 -y 40 "cd $JOJO && RUST_LOG=warn ./target/release/jojo --prompt '🍎> ' $JAM"
    tmux bind-key -n F5 send-keys -t "$SESSION" ')TOGGLE' Enter
    tmux bind-key -n F6 send-keys -t "$SESSION" ')GREEN' Enter
    tmux bind-key -n F7 send-keys -t "$SESSION" ')RED' Enter
    echo "atl-repl: session $SESSION started; attach with: tmux attach -t $SESSION" ;;
  send)  shift; tmux send-keys -t "$SESSION" "$*" Enter ;;
  show)  tmux capture-pane -p -t "$SESSION" ;;
  stop)  tmux kill-session -t "$SESSION" ;;
  *)  sed -n '2,12p' "$0" | sed 's/^#  \{0,1\}//'; exit 2 ;;
esac
