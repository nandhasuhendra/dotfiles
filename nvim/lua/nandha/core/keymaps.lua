vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- generar keymaps

keymap.set("n", "<leader>nh", ":nohl<CR>")
keymap.set("n", "x", '"_x')
keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")

-- splitting windows
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split window equal width
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

-- tabs
keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") -- go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") -- go to previous tab

-- plugin keymaps

-- vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>")

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<CR>")
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<CR>")
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
keymap.set("n", "<leader>fn", "<cmd>Telescope help_tags<CR>")

-- copy text from current cursor to end
keymap.set("n", "<leader>y", "*y")
keymap.set("n", "<leader>p", "*p")
keymap.set("n", "<leader>Y", "+y")
keymap.set("n", "<leader>P", "+p")
keymap.set("n", "<leader>cp", ':let @+=expande("%")<CR>')

-- switch buffers
keymap.set("n", "<leader>bn", ":bn<CR>")
keymap.set("n", "<leader>bp", ":bp<CR>")
keymap.set("n", "<leader>bx", ":BD<CR>")

-- disabling Arrows
keymap.set("n", "<left>", "<nop>")
keymap.set("n", "<right>", "<nop>")
keymap.set("n", "<up>", "<nop>")
keymap.set("n", "<down>", "<nop>")
keymap.set("n", "<C-s>", ":w<CR>")
keymap.set("i", "<C-s><ESC>", ":w<CR>")
keymap.set("v", "<C-s><ESC>", ":w<CR>")
