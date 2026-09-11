# Visual Studio Code

User settings for Visual Studio Code.

## Files

- `settings.json` — editor, UI, formatting, and development preferences.

## Installation

VS Code user settings are normally stored under `~/.config/Code/User/settings.json` on Linux.

```bash
mkdir -p ~/.config/Code/User
ln -sfn "$PWD/vscode/settings.json" ~/.config/Code/User/settings.json
```

## Scope

This directory contains VS Code-specific settings only. Neovim has its own independent configuration under [`../nvim`](../nvim).