return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/nvim-nio",
      "olimorris/neotest-rspec",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
    },
    keys = { "<leader>tt", "<leader>tf", "<leader>to" },
    config = function()
      vim.schedule(function()
        require("neotest").setup({
          adapters = {
            require("neotest-rspec"),
            require("neotest-jest"),
            require("neotest-python"),
            require("neotest-go"),
          },
        })
      end)
    end,
  },
}
