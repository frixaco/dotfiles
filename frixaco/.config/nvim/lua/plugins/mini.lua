return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      -- {
      --   '\\',
      --   function()
      --     local path = vim.api.nvim_buf_get_name(0)
      --     if path:match('Starter$') then
      --       require('mini.files').open(nil, false)
      --     else
      --       require('mini.files').open(path, true)
      --     end
      --   end,
      --   desc = 'Open mini.files (directory of current file)',
      -- },
      -- {
      --   '<leader>fm',
      --   function()
      --     require('mini.files').open(nil, false)
      --   end,
      --   desc = 'Open mini.files (cwd)',
      -- },
    },
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]parenthen
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup({ n_lines = 500 })

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      -- require('mini.statusline').setup({
      --   -- Content of statusline as functions which return statusline string. See
      --   -- `:h statusline` and code of default contents (used instead of `nil`).
      --   content = {
      --     -- Content for active window
      --     active = nil,
      --     -- Content for inactive window(s)
      --     inactive = nil,
      --   },
      --
      --   -- Whether to use icons by default
      --   use_icons = true,
      --
      --   -- Whether to set Vim's settings for statusline (make it always shown)
      --   set_vim_settings = true,
      -- })

      -- require('mini.files').setup({
      --   options = {
      --     use_as_default_explorer = true,
      --   },
      -- })
      -- local show_dotfiles = true
      -- local filter_show = function(fs_entry)
      --   return true
      -- end
      -- local filter_hide = function(fs_entry)
      --   return not vim.startswith(fs_entry.name, '.')
      -- end
      -- local toggle_dotfiles = function()
      --   show_dotfiles = not show_dotfiles
      --   local new_filter = show_dotfiles and filter_show or filter_hide
      --   require('mini.files').refresh({ content = { filter = new_filter } })
      -- end
      -- vim.api.nvim_create_autocmd('User', {
      --   pattern = 'MiniFilesBufferCreate',
      --   callback = function(args)
      --     local buf_id = args.data.buf_id
      --     -- Tweak left-hand side of mapping to your liking
      --     vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id })
      --   end,
      -- })

      require('mini.pairs').setup()

      local no_animation = require('mini.indentscope').gen_animation.none()
      require('mini.indentscope').setup({
        -- Draw options
        draw = {
          -- Delay (in ms) between event and start of drawing scope indicator
          delay = 100,

          -- Animation rule for scope's first drawing. A function which, given
          -- next and total step numbers, returns wait time (in ms). See
          -- |MiniIndentscope.gen_animation| for builtin options. To disable
          -- animation, use `require('mini.indentscope').gen_animation.none()`.
          animation = no_animation, --<function: implements constant 20ms between steps>,

          -- Symbol priority. Increase to display on top of more symbols.
          priority = 2,
        },

        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          -- Textobjects
          object_scope = 'ii',
          object_scope_with_border = 'ai',

          -- Motions (jump to respective border line; if not present - body line)
          goto_top = '[i',
          goto_bottom = ']i',
        },

        -- Options which control scope computation
        options = {
          -- Type of scope's border: which line(s) with smaller indent to
          -- categorize as border. Can be one of: 'both', 'top', 'bottom', 'none'.
          border = 'both',

          -- Whether to use cursor column when computing reference indent.
          -- Useful to see incremental scopes with horizontal cursor movements.
          indent_at_cursor = true,

          -- Whether to first check input line to be a border of adjacent scope.
          -- Use it if you want to place cursor on function header to get scope of
          -- its body.
          try_as_border = true,
        },

        -- Which character to use for drawing scope indicator
        symbol = '│',
      })
    end,
  },
}
