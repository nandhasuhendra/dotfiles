vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local nvimtree = require("nvim-tree")

nvimtree.setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 30,
		relativenumber = true,
	},
	renderer = {
		group_empty = true,
		indent_markers = {
			enable = true,
		},
	},
	filters = {
		dotfiles = false,
		custom = { ".DS_Store" },
	},
	git = {
		ignore = false,
	},
	actions = {
		open_file = {
			window_picker = {
				enable = false,
			},
		},
	},
})

local keymap = vim.keymap

keymap.set("n", "<leader>ee", "<cmd>:NvimTreeToggle<CR>")
keymap.set("n", "<leader>ef", "<cmd>:NvimTreeFindFileToggle<CR>")
keymap.set("n", "<leader>ec", "<cmd>:NvimTreeCollapse<CR>")
keymap.set("n", "<leader>er", "<cmd>:NvimTreeRefresh<CR>")
