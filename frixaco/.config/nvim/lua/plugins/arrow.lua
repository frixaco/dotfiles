return {
  {
    'otavioschwanck/arrow.nvim',
    event = 'VeryLazy',
    opts = {
      show_icons = true,
      leader_key = ';',
      buffer_leader_key = 'm',
      index_keys = 'afghjkl123456789zxcbnmZXVBNM,AFGHJKLwrtyuiopWRTYUIOP',
      per_buffer_config = {
        lines = 4, -- Number of lines showed on preview.
        sort_automatically = true, -- Auto sort buffer marks.
        treesitter_context = nil, -- it can be { line_shift_down = 2 }
      },
    },
  },
}
