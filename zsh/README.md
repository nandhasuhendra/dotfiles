# Zsh

Shell configuration for Zsh-based development environments.

## Files

- `.zshrc` — aliases, environment configuration, shell behavior, and integrations.

## Installation

Symlink the configuration into your home directory:

```bash
ln -sfn "$PWD/zsh/.zshrc" ~/.zshrc
```

Start a new shell or reload the file:

```bash
source ~/.zshrc
```

## Dependencies

The configuration may rely on command-line tools and shell plugins installed separately from this repository. Check `.zshrc` when adapting the setup to a new machine.

## Scope

This directory owns shell behavior only. tmux, Kitty, Ranger, and Neovim have their own configurations.