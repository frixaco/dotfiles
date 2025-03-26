-- Highlight on yank
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- WSL yank support
local clip = '/mnt/c/Windows/System32/clip.exe' -- change this path according to your mount point

if vim.fn.executable(clip) == 1 then
  vim.api.nvim_create_augroup('WSLYank', { clear = true })
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = 'WSLYank',
    callback = function()
      if vim.v.event.operator == 'y' then
        vim.fn.system(clip, vim.fn.getreg('0'))
      end
    end,
  })
end

-- C purist
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.cmd.syntax('off')
  end,
})

vim.api.nvim_create_user_command('CompRun', function()
  local file = vim.fn.expand('%')
  local file_without_ext = vim.fn.expand('%<')
  vim.cmd(string.format('!gcc -Wall -Wextra -std=c2x -pedantic -o %s %s && ./%s', file_without_ext, file, file_without_ext))
end, {
  bang = true,
})
vim.api.nvim_set_keymap('n', '<F5>', ':CompRun<CR>', { noremap = true })

vim.api.nvim_create_user_command('C', ':CodeCompanionChat', {})
