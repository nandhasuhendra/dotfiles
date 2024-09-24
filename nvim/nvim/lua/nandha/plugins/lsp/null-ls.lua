-- import null-ls plugin safely
local setup, null_ls = pcall(require, "null-ls")
if not setup then
	return
end

-- for conciseness
local formatting = null_ls.builtins.formatting -- to setup formatters
local diagnostics = null_ls.builtins.diagnostics -- to setup linters

-- to setup format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- configure null_ls
null_ls.setup({
	debug = false,
	-- setup formatters & linters
	sources = {
		null_ls.builtins.diagnostics.semgrep,

		null_ls.builtins.formatting.goimports_reviser,
		null_ls.builtins.formatting.gofumpt,
		-- null_ls.builtins.formatting.golines,

		null_ls.builtins.diagnostics.rubocop,
		null_ls.builtins.diagnostics.reek,

		null_ls.builtins.formatting.autopep8,
		null_ls.builtins.diagnostics.pylint.with({
			diagnostics_postprocess = function(diagnostic)
				diagnostic.code = diagnostic.message_id
			end,
		}),
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.black,

		formatting.prettier,
		formatting.stylua,
		diagnostics.eslint_d.with({
			condition = function(utils)
				return utils.root_has_file(".eslintrc.js")
			end,
			function(utils)
				return utils.root_has_file("Gemfile")
						and null_ls.builtins.formatting.rubocop.with({
							command = "bundle",
							args = vim.list_extend(
								{ "exec", "rubocop" },
								null_ls.builtins.formatting.rubocop._opts.args
							),
						})
					or null_ls.builtins.formatting.rubocop
			end,
		}),
	},

	on_attach = function(current_client, bufnr)
		if current_client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						filter = function(client)
							return client.name == "null-ls"
						end,
						bufnr = bufnr,
					})
				end,
			})
		end
	end,
})
