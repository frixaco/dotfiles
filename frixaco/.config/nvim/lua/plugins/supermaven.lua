return {
  {
    'supermaven-inc/supermaven-nvim',
    lazy = false,
    config = function()
      require('supermaven-nvim').setup({
        keymaps = {
          accept_suggestion = '<Tab>',
          clear_suggestion = '<C-]>',
          accept_word = '<M-a>',
        },
        ignore_filetypes = { cpp = true },
        color = {
          suggestion_color = '#ffffff',
          cterm = 244,
        },
        disable_inline_completion = false, -- disables inline completion for use with cmp
        disable_keymaps = false, -- disables built in keymaps for more manual control
      })
    end,
  },
}
