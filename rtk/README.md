# RTK

[RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer) compresses shell and CLI output before it reaches the assistant. These files hold the global configuration used across all projects.

## Files

| File | Purpose |
| --- | --- |
| `config.toml` | Global limits, tracked output, and sqlite recall mode. |
| `filters.toml` | Custom filters for `openspec validate/list` and `codegraph status/queries`. |

## Install

Copy the files into RTK's user config directory (Linux):

```bash
mkdir -p ~/.config/rtk
cp config.toml filters.toml ~/.config/rtk/
rtk trust -y          # trust the custom filters once after install/edit
rtk verify            # sanity-check hooks, filters, and recall store
```

Runtime files in `~/.config/rtk/` are copied, not linked, so live edits (e.g. `rtk config recall`) do not mutate the repo. After changing `filters.toml` here, re-copy it and re-run `rtk trust -y` — trust is hash-pinned.

## Notes

- Hooks and the OpenCode plugin / OMP extension are installed separately with `rtk init -g --opencode --hook-only --auto-patch` and `rtk init -g --agent omp --auto-patch`.
- Filter salts keep failures: `openspec validate` drops `✓`/INFO noise but preserves `✗`, error detail, and `Totals`.
- On `[+N hidden]` / `[full output: ...]` hints, recover the original with `rtk recall <hash>` instead of rerunning the command.
