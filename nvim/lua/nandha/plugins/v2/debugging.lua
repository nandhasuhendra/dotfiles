return {
  {
    "mfussenegger/nvim-dap",
    keys = { "<F5>", "<F10>", "<F11>", "<F12>", "<leader>db" },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {},
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "delve", "debugpy", "js" },
      automatic_installation = true,
    },
  },
}
