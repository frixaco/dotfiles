return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup({
        view_options = {
          -- Show files and directories that start with "."
          show_hidden = true,
        },
      })

      -- \ - should open
      vim.keymap.set('n', '\\', require('oil').open_float, { desc = 'Open parent directory' })
    end,
  },
}
