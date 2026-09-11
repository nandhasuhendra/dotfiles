return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre", "BufNewFile" },
    opts = {
      format_on_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat then return end
        return { timeout_ms = 2000, lsp_fallback = true }
      end,
      formatters_by_ft = {
        ruby = { "rubocop" },
        eruby = { "erb_format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        python = { "ruff_format" },
        go = { "gofumpt" },
        lua = { "stylua" },
        sh = { "shfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        ruby = { "rubocop" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        python = { "ruff" },
        go = { "golangcilint" },
        sh = { "shellcheck" },
        yaml = { "yamllint" },
        dockerfile = { "hadolint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
