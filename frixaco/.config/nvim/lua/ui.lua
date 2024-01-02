return {
  {
    'catppuccin/nvim',
    lazy = false,
    name = 'catppuccin',
    priority = 1000,
    opts = {
      transparent_background = true,
    },
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        globalstatus = true,
        -- catppuccin supporst it by default, no need to set
        -- theme = 'catppuccin',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_a = {
          {
            'mode',
            -- Show one word: N, I or V
            fmt = function()
              local mode = vim.fn.mode()
              if mode == 'n' then
                return 'N'
              elseif mode == 'i' then
                return 'I'
              elseif mode == 'v' then
                return 'V'
              end
            end,
          },
        },
        lualine_x = { 'filetype' },
        lualine_y = {},
      },
    },
  },

  {
    'echasnovski/mini.indentscope',
    version = '*',
    opts = {},
  },
}
