-- When and how to draw the signcolumn
vim.opt.signcolumn = 'yes:1'
-- Print the line number in front of each line
vim.opt.number = true
-- Show the line number relative to the line with the cursor in front of each line
vim.opt.relativenumber = true
-- Minimal number of screen lines to keep above and below the cursor
vim.opt.scrolloff = 8
-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
vim.opt.updatetime = 50
-- Don't pass messages to |ins-completion-menu|.
vim.opt.shortmess = 'c'
-- Number of visual spaces per TAB
vim.opt.tabstop = 4
-- Number of spaces in tab when editing
vim.opt.softtabstop = 4
-- Number of spaces to use for autoindent
vim.opt.shiftwidth = 4
-- Tabs are space
vim.opt.expandtab = true
-- Copy indent from current line when starting a new line
vim.opt.autoindent = true
-- Copy the structure of the existing lines indent when autoindenting a	new line
vim.opt.copyindent = true
-- Keep unsaved work in buffer
vim.opt.hidden = true
-- Show (partial) command in the last line of the screen.  Set this option off if your terminal is slow
vim.opt.showcmd = true
-- Highlight current line
vim.opt.cursorline = true
-- Visual autocomplete for command menu
vim.opt.wildmenu = true
-- Highlight matching brace
vim.opt.showmatch = true
-- Window will always have a status line
vim.opt.laststatus = 2
-- Do not create backup
vim.opt.backup = false
-- Disable swapfile
vim.opt.swapfile = false
-- Search as characters are entered
vim.opt.incsearch = true
-- Highlight matche
vim.opt.hlsearch = true
-- Ignore case when searching
vim.opt.ignorecase = true
-- Ignore case if searce pattern is lower case, case-sensitive otherwise
vim.opt.smartcase = true
-- Ignore files
vim.opt.wildignore:append{'*.pyc', 'build', 'dist', 'node_modules', 'coverage', 'android', 'ios', '.git'}
-- Nice menu when typing `:find *.py`
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest,list,full'
