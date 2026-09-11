return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "bashls", "basedpyright", "dockerls", "gopls", "jsonls", "marksman", "ts_ls", "yamlls" },
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
        dockerls = {},
        gopls = { settings = { gopls = { gofumpt = true, staticcheck = true, usePlaceholders = true } } },
        jsonls = {},
        marksman = {},
        ts_ls = {},
        yamlls = {},
      }
      for name, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
    end,
  },
  {
    "adam12/ruby-lsp.nvim",
    ft = { "ruby", "eruby" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {},
  },
}
