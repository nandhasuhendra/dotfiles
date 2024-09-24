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
	},
	ui = {
		border = "none",
		height = 1,
		width = 1,
		x = 0.5,
		y = 0.5,
	},
})

vim.api.nvim_set_keymap("n", "<C-e>", "", {
	noremap = true,
	callback = function()
		ranger.open(true)
	end,
})
