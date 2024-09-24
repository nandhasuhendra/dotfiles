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
		path_display = { "truncate" },
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous,
				["<C-j>"] = actions.move_selection_next,
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
			},
		},
		preview = false,
		sorting_strategy = "ascending",
		layout_strategy = "vertical",
		layout_config = {
			vertical = {
				width = 0.7,
				prompt_position = "top",
			},
		},
	},
	-- pickers = {
	-- 	find_files = {
	-- 		theme = "ivy",
	-- 	},
	-- 	live_grep = {
	-- 		theme = "ivy",
	-- 	},
	-- 	grep_string = {
	-- 		theme = "ivy",
	-- 	},
	-- 	help_tags = {
	-- 		theme = "ivy",
	-- 	},
	-- 	buffers = {
	-- 		theme = "ivy",
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
