require('nvim-lsp-installer').setup({
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})
local lspconfig = require("lspconfig")

vim.cmd("let g:coq_settings = { 'auto_start': v:true }")
local coq = require("coq")

-- Mappings
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Map the following keys only after the language server attaches to the current buffer
local function on_attach(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

lspconfig['sumneko_lua'].setup(coq.lsp_ensure_capabilities({
	on_attach = on_attach,
	settings = {
	    Lua = {
	      diagnostics = {
		-- Get the language server to recognize the `vim` global
		globals = {'vim'},
	      },
	      workspace = {
		-- Make the server aware of Neovim runtime files
		library = vim.api.nvim_get_runtime_file("", true),
	      },
	      -- Do not send telemetry data containing a randomized but unique identifier
	      telemetry = {
		enable = false,
	      },
	    },
	  },
}))
lspconfig['rust_analyzer'].setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
lspconfig['emmet_ls'].setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
lspconfig['tsserver'].setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
lspconfig['gopls'].setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
lspconfig['solargraph'].setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
lspconfig['tailwindcss'].setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
