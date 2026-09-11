# Neovim v2

A batteries-included Neovim setup for Ubuntu, designed as a daily driver for Ruby/Rails, TypeScript/JavaScript, Python, Go, Docker, YAML, JSON, Bash and Markdown.

## Install

From this repository:

```bash
./install-nvim.sh
```

The installer is idempotent and:

- installs Ubuntu system dependencies
- installs the latest stable Neovim automatically when `nvim` is not already installed
- backs up an existing `~/.config/nvim`
- symlinks this `nvim/` directory into `~/.config/nvim`
- bootstraps `lazy.nvim`
- installs plugins, LSP servers, formatters and linters through Mason
- installs Ruby LSP

The installer is intended to leave you with a ready-to-use Neovim environment after it completes. Run it again whenever the dotfiles are updated.

> The installer currently targets Ubuntu on `amd64` and `arm64` and uses the latest stable prebuilt Neovim release when Neovim is missing. Existing Neovim installations are left unchanged.

## Architecture

```text
init.lua
├── core/options.lua
├── core/keymaps.lua
├── core/autocmds.lua
├── core/diagnostics.lua
└── lazy.lua
    └── plugins/v2/*.lua
```

The plugin specs are isolated under `plugins/v2`, so the old Packer configuration remains in the repository as history without being loaded.

## Main stack

- lazy.nvim — plugin lifecycle
- native Neovim LSP — language intelligence
- nvim-lspconfig — maintained LSP configurations
- Mason + mason-lspconfig — LSP installation
- blink.cmp — completion
- nvim-treesitter — syntax and structure
- Telescope — search/navigation
- Oil — file explorer
- Gitsigns + Fugitive — Git workflow
- Conform + nvim-lint — formatting/linting
- nvim-dap + DAP UI — debugging
- Neotest — test execution
- ToggleTerm — terminal
- Trouble — diagnostics

## Language coverage

| Language | LSP | Formatting | Linting | Tests/debugging |
| --- | --- | --- | --- | --- |
| Ruby/Rails | Ruby LSP | RuboCop | RuboCop | Neotest RSpec / DAP |
| JS/TS | ts_ls + ESLint | Prettier | ESLint | Neotest Jest / DAP |
| Python | basedpyright | Ruff | Ruff | Neotest pytest / DAP |
| Go | gopls | gofumpt | golangci-lint | Neotest Go / Delve |
| Docker | dockerls | — | Hadolint | — |
| YAML/JSON | yamlls/jsonls | Prettier | yamllint | — |
| Bash | bashls | shfmt | ShellCheck | — |
| Markdown | marksman | Prettier | — | — |

## Daily keymaps

- `<Space>ff` — find files
- `<Space>fg` — live grep
- `<Space>fb` — buffers
- `<Space>fr` — recent files
- `<Space>e` — Oil explorer
- `gd` / `gr` / `gi` — LSP navigation
- `<Space>ca` — code action
- `<Space>rn` — rename
- `<Space>f` — format
- `<Space>d` — diagnostics
- `<Space>gg` — Fugitive
- `<Space>hs` / `<Space>hr` — stage/reset hunk
- `<Ctrl-\\>` — floating terminal
- `F5` / `F10` / `F11` / `F12` — debugger
- `<Space>tt` — nearest test
- `<Space>tf` — file tests

## Design decisions

1. Keep the configuration explicit instead of hiding behavior behind a distribution such as LazyVim.
2. Use Neovim's native LSP APIs rather than the deprecated `require('lspconfig').server.setup()` style.
3. Prefer project-local tools when the project provides them; Mason provides a reliable global fallback for editor tooling.
4. Keep the OS installer responsible for runtimes and system packages; keep Neovim responsible for editor tooling.
5. Preserve normal Vim motions instead of turning Neovim into a clone of VS Code.
