return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      close_if_last_window = true,

      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },

        hijack_netrw_behavior = "open_current",

        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },

      window = {
        width = 30,
      },

      default_component_configs = {
        indent = {
          with_expanders = true,
        },
      },
    },
  },
}
