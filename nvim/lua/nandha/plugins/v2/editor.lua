return {
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		lazy = false,
		config = function()
			-- require("github-theme").setup({ })
			vim.cmd("colorscheme github_dark")
		end,
	},
	-- {
	--   "navarasu/onedark.nvim",
	--   priority = 1000,
	--   config = function()
	--     require("onedark").setup({ style = "dark" })
	--     require("onedark").load()
	--   end,
	-- },
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = { options = { globalstatus = true, section_separators = "", component_separators = "" } },
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = { auto_preview = false },
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = {
				enabled = true,
				show_start = true,
				show_end = false,
			},
		},
	},
}
