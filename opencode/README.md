# OpenCode

Snapshot of the global OpenCode setup in `~/.config/opencode/`:

- `opencode.jsonc` — existing settings and MCP server definitions
- `cli.json` — terminal appearance and behavior
- `skills/` — personal skills and their supporting files
- `plugins/`, `herdr-opencode/`, and `herdr-tui-session.js` — local integrations
- `tui.jsonc` — existing legacy TUI configuration
- `package.json` — dependency declaration (install dependencies locally)

To install OpenCode V2 (if missing) and link this setup on Linux or macOS, run
from the dotfiles repository:

```sh
./install-opencode.sh
```

The installer backs up existing files or directories at each link path and is
safe to re-run. It keeps `node_modules/`, service settings, and local state
untouched, and copies `package.json` only if absent. Install its dependencies
locally if your OpenCode version needs them. Adjust the hard-coded home path in
`opencode.jsonc` for another username; MCP commands require `uvx` and `npx`.
MCP OAuth credentials and provider sign-ins are intentionally **not** stored
here and must be authorized separately.

`opencode.jsonc` is a copy of the existing configuration, including older
OpenCode settings. It has not been migrated to the current V2 format.
