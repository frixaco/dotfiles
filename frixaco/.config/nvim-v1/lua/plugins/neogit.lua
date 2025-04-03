return {
  {
    'NeogitOrg/neogit',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
      -- "ibhagwan/fzf-lua",
    },
    keys = {
      {
        '<leader>gg',
        ':Neogit<CR>',
        desc = 'Open Neogit',
        mode = { 'n', 't' },
        silent = true,
      },
    },
    config = true,
  },
}
