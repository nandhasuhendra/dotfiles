# tmux

Configuration for the tmux terminal multiplexer.

## Files

- `.tmux.conf` — tmux options, keybindings, and behavior.

## Installation

Symlink the configuration to your home directory:

```bash
ln -sfn "$PWD/tmux/.tmux.conf" ~/.tmux.conf
```

Reload an existing tmux server with:

```bash
tmux source-file ~/.tmux.conf
```

## Scope

This configuration controls tmux sessions, panes, windows, and navigation. Terminal emulator and shell settings are maintained separately.