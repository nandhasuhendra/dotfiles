local group = vim.api.nvim_create_augroup("nandha", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(args)
    if vim.bo[args.buf].buftype == "" then
      vim.cmd([[silent! undojoin]])
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "help", "qf", "lspinfo", "checkhealth" },
  callback = function(args) vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true }) end,
})
