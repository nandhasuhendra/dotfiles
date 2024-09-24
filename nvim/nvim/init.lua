require("nandha.plugins-setup")
require("nandha.core.colorscheme")
require("nandha.core.options")
require("nandha.core.keymaps")
require("nandha.plugins.ranger")
require("nandha.plugins.webdevicons")
require("nandha.plugins.comment")
require("nandha.plugins.lualine")
require("nandha.plugins.telescope")
require("nandha.plugins.nvim-cmp")
require("nandha.plugins.lsp.mason")
require("nandha.plugins.lsp.lspsaga")
require("nandha.plugins.lsp.lspconfig")
require("nandha.plugins.lsp.null-ls")
require("nandha.plugins.anyjump")
require("nandha.plugins.autopairs")
require("nandha.plugins.treesitter")
require("nandha.plugins.gitsigns")
require("nandha.plugins.easypicker")
-- require("nandha.plugins.nvim-tree")
-- require("nandha.plugins.rainbow-csv")
-- require("nandha.plugins.rainbow-parentheses")

if os.getenv("WSL_DISTRO_NAME") ~= nil then
	vim.g.clipboard = {
		name = "wsl clipboard",
		copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
		paste = { ["+"] = { "nvim_paste" }, ["*"] = { "nvim_paste" } },
		cache_enabled = false,
	}
end
