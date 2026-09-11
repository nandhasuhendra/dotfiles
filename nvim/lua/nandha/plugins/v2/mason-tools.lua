return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    lazy = false,
    cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsUpdateSync",
      "MasonToolsClean",
    },
    opts = {
      ensure_installed = {
        -- CLI tools
        "tree-sitter-cli",

        -- LSP servers
        "bash-language-server",
        "basedpyright",
        "css-lsp",
        "dockerfile-language-server",
        "eslint-lsp",
        "gopls",
        "html-lsp",
        "json-lsp",
        "marksman",
        "typescript-language-server",
        "yaml-language-server",

        -- Formatters / linters
        "rubocop",
        "prettier",
        "eslint_d",
        "ruff",
        "gofumpt",
        "stylua",
        "shfmt",
        "shellcheck",
        "yamllint",
        "hadolint",

        -- Debug adapters
        "delve",
        "debugpy",
        "js-debug-adapter",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 1000,
    },
  },
}
