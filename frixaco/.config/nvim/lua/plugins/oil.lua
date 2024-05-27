return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup()

      -- \ - should open
      vim.keymap.set('n', '\\', require('oil').open, { desc = 'Open parent directory' })
    end,
  },
}
