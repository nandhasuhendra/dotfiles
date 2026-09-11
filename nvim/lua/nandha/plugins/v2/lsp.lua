return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      -- Installation is handled by mason-tool-installer so the bootstrap
      -- script can install everything deterministically in headless mode.
      ensure_installed = {},
      automatic_enable = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local servers = {
        bashls = {},
        basedpyright = {},
        cssls = {},
        dockerls = {},
        eslint = {},
        gopls = { settings = { gopls = { gofumpt = true, staticcheck = true, usePlaceholders = true } } },
        html = {},
        jsonls = {},
        marksman = {},
        ts_ls = {},
        yamlls = {},
        ruby_lsp = {
          cmd = { "ruby-lsp" },
          filetypes = { "ruby", "eruby" },
          root_markers = { "Gemfile", ".git" },
        },
      }
      for name, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
    end,
  },
}
