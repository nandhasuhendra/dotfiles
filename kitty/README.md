# Kitty

Configuration for the Kitty terminal emulator.

## Files

- `kitty.conf` — main Kitty configuration.

## Installation

Copy or symlink `kitty.conf` to Kitty's configuration directory:

```bash
mkdir -p ~/.config/kitty
ln -sfn "$PWD/kitty/kitty.conf" ~/.config/kitty/kitty.conf
```

Restart Kitty after changing the configuration.

## Scope

This directory contains only Kitty-specific settings. Terminal multiplexer, shell, and editor configuration live in their respective directories.