local tele_setup, telescope = pcall(require, "telescope")
if not tele_setup then
	print("telescope not found!")
	return
end

local action_setup, actions = pcall(require, "telescope.actions")
if not action_setup then
	print("telescope.actions not found!")
	return
end

telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous,
				["<C-j>"] = actions.move_selection_next,
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
			},
		},
	},
	-- pickers = {
	-- 	find_files = {
	-- 		theme = "dropdown",
	-- 	},
	-- 	live_grep = {
	-- 		theme = "dropdown",
	-- 	},
	-- 	grep_string = {
	-- 		theme = "dropdown",
	-- 	},
	-- 	help_tags = {
	-- 		theme = "dropdown",
	-- 	},
	-- 	buffers = {
	-- 		theme = "dropdown",
	-- 		ignore_current_buffer = true,
	-- 		sort_lastused = true,
	-- 	},
	-- },
	extensions = {
		file_browser = {
			theme = "ivy",
			hijack_netrw = true,
			hidden = { file_browser = true, folder_browser = true },
		},
	},
})

telescope.load_extension("fzf")
