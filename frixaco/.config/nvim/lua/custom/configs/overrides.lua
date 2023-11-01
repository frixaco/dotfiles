local M = {}

M.treesitter = {
	ensure_installed = {
		"vim",
		"lua",
		"html",
		"css",
		"javascript",
		"typescript",
		"tsx",
		"c",
		"markdown",
		"markdown_inline",
		"graphql",
		"go",
		"python",
	},
	indent = {
		enable = true,
		-- disable = {
		--   "python"
		-- },
	},
}

M.mason = {
	ensure_installed = {
		-- lua stuff
		"lua-language-server",
		"stylua",

		-- web dev stuff
		"css-lsp",
		"html-lsp",
		"typescript-language-server",
		"emmet-language-server",
		"prettierd",
		"tailwindcss-language-server",
		"eslint-lsp",

		-- c/cpp stuff
		"clangd",
		"clang-format",

		-- python
		"blackd-client",
		"ruff-lsp",
		"pyright",

		-- golang
		"gopls",
	},
}

-- git support in nvimtree
M.nvimtree = {
	git = {
		enable = true,
		ignore = false,
	},

	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
}

M.telescope = {
	pickers = {
		find_files = {
			find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
		},
	},
}

return M
