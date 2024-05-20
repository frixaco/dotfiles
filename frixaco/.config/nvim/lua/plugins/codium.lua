return {
  {
    'Exafunction/codeium.vim',
    event = 'VeryLazy',
    cmd = 'Codeium',
    config = function()
      vim.keymap.set('i', '<M-a>', function()
        return vim.fn['codeium#Accept']()
      end, { expr = true, silent = true })
    end,
  },
}
