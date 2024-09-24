local keymap = vim.keymap
local global = vim.g

global.any_jump_list_numbers = 1

-- AnyJump
keymap.set("n", "gd", ":AnyJump<CR>")
