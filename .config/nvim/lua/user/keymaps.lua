vim.g.mapleader = "\\"

vim.api.nvim_set_keymap("n", "<Leader>cr", ":luafile $MYVIMRC<CR>", {
    noremap = true
})
vim.api.nvim_set_keymap("n", "<Leader>ce", ":e $MYVIMRC<CR>", {
    noremap = true
})

-- Clear highlight
vim.keymap.set('n', '<Esc>', ':noh<CR>', {
    noremap = true
})

-- Copy to clipboard in normal and visual mode
vim.api.nvim_set_keymap('n', '<Leader>y', '"+y', {
    noremap = true
})
vim.api.nvim_set_keymap('v', '<Leader>y', '"+y', {
    noremap = true
})
vim.api.nvim_set_keymap('n', '<Leader>p', '"+p', {
    noremap = true
})
vim.api.nvim_set_keymap('v', '<Leader>p', '"+p', {
    noremap = true
})
