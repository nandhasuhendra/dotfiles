vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = false
opt.breakindent = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.confirm = true
opt.inccommand = "split"
opt.list = true
opt.listchars = { tab = "│ ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }

-- Keep code visible on open; use native z-motions to fold when needed.
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "1"
_G.NandhaFoldText = function()
  local first = vim.fn.getline(vim.v.foldstart)
  local hidden = vim.v.foldend - vim.v.foldstart
  return string.format("%s  ⋯ %d line%s folded", first, hidden, hidden == 1 and "" or "s")
end
opt.foldtext = "v:lua.NandhaFoldText()"
