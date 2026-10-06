# Herdr

The tracked `config.toml` keeps the Dracula theme and compact two-line sidebar
layouts for agents and spaces.

To install Herdr (if missing) and link its config on Linux or macOS, run from
the dotfiles repository:

```sh
./install-herdr.sh
```

The installer backs up an existing config before linking and reloads a running
server when possible. Re-running it leaves an already linked config alone. It
does not link the whole directory: Herdr also stores runtime files there.
