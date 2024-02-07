-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable startup screen
-- vim.opt.shortmess:append({ I = true })

-- Easier switch to command mode
vim.keymap.set('n', ';', ':')

-- Set highlight on search
vim.o.hlsearch = false

-- Set cursorline
vim.wo.cursorline = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Wrap lines
vim.o.wrap = false

-- Sync clipboard between OS and Neovim.
-- Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Tabs and indenting
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Sets the transparency of the popup menu (the menu that appears when you use autocompletion). The value can be between 0 (opaque) and 100 (fully transparent)
vim.o.pumblend = 0
-- Sets the transparency of windows when they are in a non-current split. Like pumblend, the value can be between 0 and 100
vim.o.winblend = 0
