local opt = vim.opt -- for conciseness

vim.scriptencoding = "utf-8"
opt.fileencoding = "utf-8"

opt.title = true

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
opt.smartindent = true
-- opt.listchars = "eol:¬,tab:» ,space:.,trail:~"

-- line wrapping
opt.wrap = true
opt.linebreak = true

-- scroll
opt.scrolloff = 10

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
opt.splitkeep = "cursor"

opt.iskeyword:append("-")

-- turned off swapfile
opt.swapfile = false

-- change buffer without save
opt.hidden = true

-- command
opt.showcmd = true
opt.cmdheight = 0
opt.laststatus = 0
opt.inccommand = "split"

-- ignore dir
opt.wildignore:append({ "*/node_modules/*" })

-- format options
opt.formatoptions:append({ "r" })

-- fold
opt.foldenable = true
opt.foldmethod = "indent"
opt.foldcolumn = "1"
opt.foldlevelstart = 99
