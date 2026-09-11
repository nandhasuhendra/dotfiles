return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    opts = { direction = "float", float_opts = { border = "rounded" }, open_mapping = [[<c-\>]] },
  },
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
  },
}
