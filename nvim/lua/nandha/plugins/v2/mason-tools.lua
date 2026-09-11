return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
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
      },
      auto_update = false,
      run_on_start = true,
    },
  },
}
