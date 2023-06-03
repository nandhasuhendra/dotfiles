local status, ranger = pcall(require, "ranger-nvim")
if not status then
  print("Ranger not found!")
  return
end

ranger.setup({
  replace_netrw = true,
  keybinds = {
    ["ov"] = ranger.OPEN_MODE.vsplit,
    ["oh"] = ranger.OPEN_MODE.split,
    ["ot"] = ranger.OPEN_MODE.tabedit,
    ["or"] = ranger.OPEN_MODE.rifle,
  },
})

vim.api.nvim_set_keymap("n", "<C-e>", "", {
  noremap = true,
  callback = function()
    ranger.open(true)
  end,
})

