local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

-- This autocommand can be placed in your init.vim,
-- or any other startup file as per your setup. Placing this
-- in plugins.lua could look like this:
vim.cmd([[
  augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")

	use("nvim-lua/plenary.nvim") -- lua functions that many plugins use

	-- preferred colorscheme
	use("olimorris/onedarkpro.nvim")
	use({ "scottmckendry/cyberdream.nvim" })

	use("christoomey/vim-tmux-navigator") -- tmux & split window navigation
	use("szw/vim-maximizer") -- maximizes and restores current window
	use("tpope/vim-surround") -- surrounding blocker text
	use("vim-scripts/ReplaceWithRegister")
	use("numToStr/Comment.nvim") -- commenting with gc
	use("nvim-lualine/lualine.nvim") -- statusLine
	use("kyazdani42/nvim-web-devicons") -- web devicons for terminal
	use("cameron-wags/rainbow_csv.nvim") -- rainbow_csv
	use("HiPhish/nvim-ts-rainbow2") -- rainbow parentheses

	-- Fuzzy findinds
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependecy of fuzzy funding
	use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" })
	use({ "axkirillov/easypick.nvim", requires = "nvim-telescope/telescope.nvim" })

	-- Ranger
	use("kelly-lin/ranger.nvim")

	-- nvim-tree
	use("nvim-tree/nvim-tree.lua")

	-- autocompletion
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")

	-- snippets
	use("L3MON4D3/LuaSnip")
	use("saadparwaiz1/cmp_luasnip")
	use("rafamadriz/friendly-snippets")

	-- managing & installing lsp servers
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")

	-- configuring lsp server
	use("neovim/nvim-lspconfig")
	use({
		"nvimdev/lspsaga.nvim",
		branch = "main",
		requires = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "nvim-treesitter/nvim-treesitter" },
		},
	}) -- enhanced lsp uis
	use("jose-elias-alvarez/typescript.nvim") -- additional functionality for typescript server (e.g. rename file & update imports)
	use("onsails/lspkind.nvim") -- vs-code like icons for autocompletion

	-- any-jump
	use({ "pechorin/any-jump.vim" })

	-- formatting & linting
	use("jose-elias-alvarez/null-ls.nvim") -- configure formatters & linters
	use("jayp0521/mason-null-ls.nvim") -- bridges gap b/w mason & null-ls

	-- treesitter configuration
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
	})

	-- auto closing
	use("windwp/nvim-autopairs") -- autoclose parens, brackets, quotes, etc...
	use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" }) -- autoclose tags
	use({ "RRethy/nvim-treesitter-endwise", after = "nvim-treesitter" }) -- autoclose for ruby

	-- git integration
	use("lewis6991/gitsigns.nvim") -- show line modifications on left hand side

	-- gounit
	use("hexdigest/gounit-vim")

	-- swagger
	use({ "shuntaka9576/preview-swagger.nvim", run = "yarn install" })

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end)
