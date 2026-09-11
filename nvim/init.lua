require("nandha.core.options")
require("nandha.core.keymaps")
require("nandha.core.autocmds")
require("nandha.core.diagnostics")
require("nandha.lazy")

if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "wsl clipboard",
    copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
    paste = { ["+"] = { "powershell.exe", "-NoProfile", "-Command", "Get-Clipboard" } },
    cache_enabled = true,
  }
end
