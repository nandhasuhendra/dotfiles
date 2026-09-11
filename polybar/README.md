# Polybar

Desktop status bar configuration for Polybar.

## Structure

- `config` — primary Polybar configuration.
- `master.conf` — main bar configuration.
- `modules.conf` — shared module definitions.
- `modules/` — module-specific configuration.
- `scripts/` — helper scripts used by modules.

## Installation

Symlink the configuration directory or individual files into your Polybar configuration location, commonly `~/.config/polybar`.

```bash
mkdir -p ~/.config/polybar
ln -sfn "$PWD/polybar/config" ~/.config/polybar/config
```

Adjust the target files if your Polybar setup uses `master.conf` or `modules.conf` as its entrypoint.

## Scope

This configuration is intended for Linux desktop environments using Polybar. It is independent from Kitty, tmux, Zsh, and Neovim.