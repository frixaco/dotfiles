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
