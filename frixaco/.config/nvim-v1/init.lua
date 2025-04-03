# TODO: REWRITE WITH FULL WHICH_KEY SUPPORT AND NO OVERMAPS
require('settings')
require('keymaps')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  defaults = { lazy = true },
  install = { colorscheme = { 'catppuccin' } },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        '2html_plugin',
        'tohtml',
        'getscript',
        'getscriptPlugin',
        'gzip',
        'logipat',
        'netrw',
        'netrwPlugin',
        'netrwSettings',
        'netrwFileHandlers',
        'matchit',
        'tar',
        'tarPlugin',
        'rrhelper',
        'spellfile_plugin',
        'vimball',
        'vimballPlugin',
        'zip',
        'zipPlugin',
        'tutor',
        'rplugin',
        'syntax',
        'synmenu',
        'optwin',
        'compiler',
        'bugreport',
        'ftplugin',
        'matchparen',
      },
    },
  },
})

require('autocmds')

local terminal_buffers = {}

function ToggleTerminal()
    local current_tab = vim.api.nvim_get_current_tabpage()
    local term_buf = terminal_buffers[current_tab]
    local term_win = nil

    -- Check if the terminal buffer is already open in a window
    if term_buf then
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
            if vim.api.nvim_win_get_buf(win) == term_buf then
                term_win = win
                break
            end
        end
    end

    if term_win then
        -- If terminal is open, hide it by closing the window
        vim.api.nvim_win_close(term_win, false)
    else
        if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
            -- If there's no terminal buffer or it's invalid, create a new one
            vim.cmd('split')
            vim.cmd('terminal')
            term_buf = vim.api.nvim_get_current_buf()
            terminal_buffers[current_tab] = term_buf
        else
            -- If the terminal buffer exists, open it in a new split
            vim.cmd('split')
            vim.api.nvim_set_current_buf(term_buf)
        end
    end
end

vim.api.nvim_set_keymap('n', '<leader>tt', ':lua ToggleTerminal()<CR>', { noremap = true, silent = true })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
