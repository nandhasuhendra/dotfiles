# Vim

Legacy Vim configuration retained for environments where Neovim is unavailable.

## Files

- `.vimrc` — Vim configuration and plugin setup.

## Installation

Symlink the configuration into your home directory:

```bash
ln -sfn "$PWD/vim/.vimrc" ~/.vimrc
```

## Neovim migration

For the actively maintained editor setup, use [`../nvim`](../nvim). The Neovim configuration is a separate modern stack and does not depend on this legacy Vim configuration.

## Scope

This directory is intentionally kept independent so existing Vim workflows remain usable during migration.