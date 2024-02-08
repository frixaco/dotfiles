return {
  {
    'echasnovski/mini.files',
    event = 'VeryLazy',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      {
        '<leader>fm',
        function()
          require('mini.files').open()
        end,
        desc = 'Open mini.files (directory of current file)',
      },
      {
        '<leader>fM',
        function()
          require('mini.files').open(vim.loop.cwd(), true)
        end,
        desc = 'Open mini.files (cwd)',
      },
    },
    config = function()
      require('mini.files').setup({
        windows = {
          preview = false,
          width_focus = 30,
          width_preview = 30,
        },
        options = {
          -- Whether to use for editing directories
          -- Disabled by default in LazyVim because neo-tree is used for that
          use_as_default_explorer = true,
        },
      })

      local show_dotfiles = true
      local filter_show = function(fs_entry)
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
      end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require('mini.files').refresh({ content = { filter = new_filter } })
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id
          -- Tweak left-hand side of mapping to your liking
          vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id })
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event)
          require('lazyvim.util').lsp.on_rename(event.data.from, event.data.to)
        end,
      })
    end,
  },
}
