# Neovim v2

A batteries-included Neovim setup for Ubuntu and macOS, designed as a daily driver for Ruby/Rails, TypeScript/JavaScript, Python, Go, Docker, YAML, JSON, Bash and Markdown.

## Install

From this repository:

```bash
./install-nvim.sh
```

The installer is idempotent and:

- detects Linux/Ubuntu or macOS automatically
- installs required system dependencies
- installs Homebrew automatically on macOS when it is missing
- installs the latest available Neovim package when `nvim` is not already installed
- backs up an existing `~/.config/nvim`
- symlinks this `nvim/` directory into `~/.config/nvim`
- bootstraps `lazy.nvim`
- installs plugins, LSP servers, formatters and linters through Mason
- installs Ruby LSP using Homebrew Ruby on macOS

The installer is intended to leave you with a ready-to-use Neovim environment after it completes. Run it again whenever the dotfiles are updated.

> Linux currently targets Ubuntu on `amd64` and `arm64`. macOS supports both Apple Silicon and Intel Macs. On macOS, Xcode Command Line Tools are required; if they are missing, the installer tells you how to install them and should be run again afterward.

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
- Neo-tree — file explorer
- Gitsigns + LazyGit — Git workflow
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

## Keymaps

`<Space>` is the leader key. Unless noted otherwise, mappings below are for **Normal mode**.

### General

| Key | Action |
| --- | --- |
| `<Esc>` | Clear search highlighting |
| `<Space>q` | Quit with confirmation |
| `<Space>w` | Save file |
| `<Space>x` | Save and close current buffer |

### Files & search

| Key | Action |
| --- | --- |
| `<Space>e` | Toggle Neo-tree file explorer |
| `<Space>ff` | Find files with Telescope |
| `<Space>fg` | Live grep with Telescope |
| `<Space>fb` | List open buffers |
| `<Space>fr` | Recent files |
| `<Space>fh` | Search Neovim help tags |
| `<Space>sg` | Search word under cursor |
| `<Space>p` | Switch projects |
| `<Space>mp` | Toggle Markdown preview in browser |

### Windows & navigation

| Key | Action |
| --- | --- |
| `<Space>sv` | Split window vertically |
| `<Space>sh` | Split window horizontally |
| `<Space>se` | Equalize window sizes |
| `<Space>sx` | Close current window |
| `<Ctrl-h>` | Move to left window |
| `<Ctrl-j>` | Move to lower window |
| `<Ctrl-k>` | Move to upper window |
| `<Ctrl-l>` | Move to right window |

### Buffers

| Key | Action |
| --- | --- |
| `<Space>bd` | Delete current buffer |
| `<Space>bn` | Go to next buffer |
| `<Space>bp` | Go to previous buffer |
| `<Space>bo` | Delete all other buffers |

### LSP & code navigation

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Show hover documentation |
| `<Space>ca` | Code action |
| `<Space>rn` | Rename symbol |
| `<Space>f` | Format current buffer |
| `<Space>d` | Toggle diagnostics with Trouble |

### Git

| Key | Action |
| --- | --- |
| `<Space>gg` | Open LazyGit |
| `<Space>gb` | Show Git blame for current line |
| `]c` | Jump to next Git hunk |
| `[c` | Jump to previous Git hunk |
| `<Space>hs` | Stage current hunk |
| `<Space>hr` | Reset current hunk |
| `<Space>hp` | Preview current hunk |

`<Space>hs` and `<Space>hr` also work in Visual mode for selected hunks.

### Terminal

| Key | Action |
| --- | --- |
| `<Ctrl-\\>` | Toggle terminal |

### Debugging

| Key | Action |
| --- | --- |
| `F5` | Continue / start debugging |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |
| `<Space>db` | Toggle breakpoint |
| `<Space>du` | Toggle DAP UI |

### Testing

| Key | Action |
| --- | --- |
| `<Space>tt` | Run nearest test |
| `<Space>tf` | Run tests in current file |
| `<Space>to` | Toggle Neotest output panel |

### Neovim & plugin management

| Key | Action |
| --- | --- |
| `<Space>l` | Open Lazy plugin manager |

## Useful commands

These commands are not keymaps but are useful for maintaining the environment:

| Command | Action |
| --- | --- |
| `:Lazy` | Open plugin manager |
| `:Mason` | Open Mason package manager |
| `:MasonToolsInstallSync` | Install configured Mason tools synchronously |
| `:checkhealth` | Run Neovim health checks |
| `:MarkdownPreview` | Open current Markdown file preview in browser |
| `:MarkdownPreviewStop` | Stop current Markdown preview |

## Design decisions

1. Keep the configuration explicit instead of hiding behavior behind a distribution such as LazyVim.
2. Use Neovim's native LSP APIs rather than the deprecated `require('lspconfig').server.setup()` style.
3. Prefer project-local tools when the project provides them; Mason provides a reliable global fallback for editor tooling.
4. Keep the OS installer responsible for runtimes and system packages; keep Neovim responsible for editor tooling.
5. Use Homebrew-managed runtimes on macOS instead of relying on Apple's system Ruby or other developer runtimes.
6. Preserve normal Vim motions instead of turning Neovim into a clone of VS Code.
