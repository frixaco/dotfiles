-- Order is important
local modules = {"user.options", "user.keymaps", "user.plugins", "user.lsp"}

-- Refresh module cache
for k, v in pairs(modules) do
    package.loaded[v] = nil
    require(v)
end

vim.api.nvim_set_keymap("n", "<Leader>cr", ":luafile $MYVIMRC<CR>", {
    noremap = true
})
vim.api.nvim_set_keymap("n", "<Leader>ce", ":e $MYVIMRC<CR>", {
    noremap = true
})
