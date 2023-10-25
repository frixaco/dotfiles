local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- if you just want default config for the servers then put them in a table
local servers =
	{ "html", "cssls", "tsserver", "clangd", "eslint", "ruff_lsp", "tailwindcss", "emmet_language_server", "pyright" }

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

-- lspconfig.pyright.setup { blabla}
lspconfig.gopls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
})

lspconfig.tailwindcss.setup({
	settings = {
		tailwindCSS = {
			experimental = {
				classRegex = {
					{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
					{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
				},
			},
		},
	},
})

vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = true,
	signs = true,
	underline = false,
})
