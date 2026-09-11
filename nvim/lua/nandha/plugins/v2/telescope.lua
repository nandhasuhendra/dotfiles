return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
      },
      extensions = { fzf = {} },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = { detection_methods = { "pattern" }, patterns = { ".git", "Gemfile", "package.json", "go.mod", "pyproject.toml" } },
  },
}
