# Herdr

The tracked `config.toml` configures a slim, borderless Dracula theme with
compact styled sidebar rows, visible top bar with clock/zoom, floating toasts,
and a tree view for subagents (`├─`, `└─`) with live status indicators.

To install Herdr (if missing) and link its config on Linux or macOS, run from
the dotfiles repository:

```sh
./herdr/install-herdr.sh
```

The installer backs up an existing config before linking and reloads a running
server when possible. Re-running it leaves an already linked config alone. It
does not link the whole directory: Herdr also stores runtime files there.
