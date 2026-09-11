vim.g.mapleader = " "
vim.g.maplocalleader = " "
local map = vim.keymap.set
local opts = { silent = true }

local function listed_buffers()
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())
end

local function delete_current_buffer()
  local current = vim.api.nvim_get_current_buf()

  if #listed_buffers() == 1 then
    vim.cmd("enew")
    vim.cmd("bdelete " .. current)
    return
  end

  vim.cmd("bdelete " .. current)
end

local function delete_other_buffers()
  local current = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(listed_buffers()) do
    if buf ~= current then
      vim.cmd("bdelete " .. buf)
    end
  end
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>q", "<cmd>confirm q<CR>", opts)
map("n", "<leader>w", "<cmd>w<CR>", opts)
map("n", "<leader>x", "<cmd>x<CR>", opts)
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", opts)
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)
map("n", "<leader>sg", "<cmd>Telescope grep_string<CR>", opts)

map("n", "<leader>sv", "<C-w>v", opts)
map("n", "<leader>sh", "<C-w>s", opts)
map("n", "<leader>se", "<C-w>=", opts)
map("n", "<leader>sx", "<cmd>close<CR>", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

map("n", "<leader>bd", delete_current_buffer, { desc = "Buffer: delete" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Buffer: next" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Buffer: previous" })
map("n", "<leader>bo", delete_other_buffers, { desc = "Buffer: delete others" })

map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
map("n", "<leader>rn", vim.lsp.buf.rename, opts)
map("n", "K", vim.lsp.buf.hover, opts)
map("n", "gd", vim.lsp.buf.definition, opts)
map("n", "gD", vim.lsp.buf.declaration, opts)
map("n", "gi", vim.lsp.buf.implementation, opts)
map("n", "gr", vim.lsp.buf.references, opts)
map("n", "<leader>f", function() require("conform").format({ async = true, lsp_fallback = true }) end, opts)
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<CR>", opts)

map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Git: LazyGit" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", opts)
map("n", "]c", function() require("gitsigns").next_hunk() end, opts)
map("n", "[c", function() require("gitsigns").prev_hunk() end, opts)
map({ "n", "v" }, "<leader>hs", function() require("gitsigns").stage_hunk() end, opts)
map({ "n", "v" }, "<leader>hr", function() require("gitsigns").reset_hunk() end, opts)
map("n", "<leader>hp", function() require("gitsigns").preview_hunk() end, opts)

map("n", "<C-\\>", "<cmd>ToggleTerm<CR>", opts)
map("n", "<F5>", function() require("dap").continue() end, opts)
map("n", "<F10>", function() require("dap").step_over() end, opts)
map("n", "<F11>", function() require("dap").step_into() end, opts)
map("n", "<F12>", function() require("dap").step_out() end, opts)
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, opts)
map("n", "<leader>du", function() require("dapui").toggle() end, opts)

map("n", "<leader>tt", function() require("neotest").run.run() end, opts)
map("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, opts)
map("n", "<leader>to", function() require("neotest").output_panel.toggle() end, opts)

map("n", "<leader>p", "<cmd>Telescope projects<CR>", opts)
map("n", "<leader>l", "<cmd>Lazy<CR>", opts)
