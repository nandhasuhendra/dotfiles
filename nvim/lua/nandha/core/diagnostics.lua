vim.diagnostic.config({
  underline = true,
  virtual_text = { spacing = 2, source = "if_many" },
  signs = true,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})
