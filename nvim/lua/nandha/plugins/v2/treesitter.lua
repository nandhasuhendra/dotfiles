return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "css",
        "dockerfile",
        "go",
        "html",
        "javascript",
        "json",
        "kotlin",
        "lua",
        "markdown",
        "python",
        "ruby",
        "sql",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup()

      local function install_parsers()
        if vim.fn.executable("tree-sitter") == 1 then
          require("nvim-treesitter").install(opts.ensure_installed)
        end
      end

      install_parsers()

      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        once = true,
        callback = install_parsers,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)

          if ok then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
