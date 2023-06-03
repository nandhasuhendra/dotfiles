local opt = vim.opt -- for conciseness

-- line numers
opt.ruler = true
opt.relativenumber = true
opt.number = true
opt.numberwidth = 3

-- tabs & indentation
opt.list = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.listchars = "eol:¬,tab:»-,space:.,trail:~"

-- line wrapping
opt.wrap = true
opt.linebreak = true

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true

-- apparance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

-- turned off swapfile
opt.swapfile = false

-- change buffer without save
opt.hidden = true
