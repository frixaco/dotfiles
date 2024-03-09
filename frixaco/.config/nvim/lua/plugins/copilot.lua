return {
  -- {
  --   'zbirenbaum/copilot.lua',
  --   event = 'VeryLazy',
  --   cmd = 'Copilot',
  --   config = function()
  --     require('copilot').setup({
  --       panel = {
  --         enabled = true,
  --         auto_refresh = false,
  --         keymap = {
  --           jump_prev = '[[',
  --           jump_next = ']]',
  --           accept = '<CR>',
  --           refresh = 'gr',
  --           open = '<M-CR>',
  --         },
  --         layout = {
  --           position = 'bottom', -- | top | left | right
  --           ratio = 0.4,
  --         },
  --       },
  --       suggestion = {
  --         enabled = true,
  --         auto_trigger = true,
  --         debounce = 75,
  --         keymap = {
  --           accept = '<M-a>',
  --           accept_word = false,
  --           accept_line = false,
  --           next = '<M-]>',
  --           prev = '<M-[>',
  --           dismiss = '<C-]>',
  --         },
  --       },
  --       filetypes = {
  --         ['.'] = true,
  --       },
  --       copilot_node_command = 'node', -- Node.js version must be > 18.x
  --       server_opts_overrides = {},
  --     })
  --   end,
  -- },
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
