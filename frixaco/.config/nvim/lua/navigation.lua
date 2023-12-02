return {
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      {
        'nvim-treesitter/nvim-treesitter-context',
        opts = {
          max_lines = 1,
        },
      },
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    build = ':TSUpdate',
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
        config = function()
          require('telescope').load_extension 'fzf'
        end,
      },
    },
  },

  -- {
  --   'nvim-telescope/telescope-frecency.nvim',
  --   config = function()
  --     require('telescope').load_extension 'frecency'
  --   end,
  -- },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },

  {
    'nvim-pack/nvim-spectre',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      {
        '<leader>S',
        mode = { 'n' },
        function()
          require('spectre').toggle()
        end,
        desc = 'Toggle Spectre',
      },
      {
        '<leader>sw',
        mode = { 'n' },
        function()
          require('spectre').open_visual { select_word = true }
        end,
        desc = 'Search current word',
      },
      {
        '<leader>sw',
        mode = { 'v' },
        function()
          require('spectre').open_visual()
        end,
        desc = 'Search current word',
      },
      {
        '<leader>sp',
        mode = { 'n' },
        function()
          require('spectre').open_file_search { select_word = true }
        end,
        desc = 'Search on current file',
      },
    },
  },

  -- Auto pairs
  {
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        '<leader>up',
        function()
          local Util = require 'lazy.core.util'
          vim.g.minipairs_disable = not vim.g.minipairs_disable
          if vim.g.minipairs_disable then
            Util.warn('Disabled auto pairs', { title = 'Option' })
          else
            Util.info('Enabled auto pairs', { title = 'Option' })
          end
        end,
        desc = 'Toggle auto pairs',
      },
    },
  },

  -- For text that includes surrounding characters like brackets or quotes, this allows you
  -- to select the text inside, change or modify the surrounding characters and more.
  {
    'echasnovski/mini.surround',
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require('lazy.core.config').spec.plugins['mini.surround']
      local opts = require('lazy.core.plugin').values(plugin, 'opts', false)
      local mappings = {
        { opts.mappings.add, desc = 'Add surrounding', mode = { 'n', 'v' } },
        { opts.mappings.delete, desc = 'Delete surrounding' },
        { opts.mappings.find, desc = 'Find right surrounding' },
        { opts.mappings.find_left, desc = 'Find left surrounding' },
        { opts.mappings.highlight, desc = 'Highlight surrounding' },
        { opts.mappings.replace, desc = 'Replace surrounding' },
        { opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
      },
    },

    {
      'echasnovski/mini.files',
      opts = {
        windows = {
          preview = true,
          width_focus = 30,
          width_preview = 30,
        },
        options = {
          -- Whether to use for editing directories
          -- Disabled by default in LazyVim because neo-tree is used for that
          use_as_default_explorer = false,
        },
      },
      keys = {
        {
          '<leader>fm',
          function()
            require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
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
      config = function(_, opts)
        require('mini.files').setup(opts)

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
          require('mini.files').refresh { content = { filter = new_filter } }
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
  },

  {
    'hedyhli/outline.nvim',
    config = function()
      -- Example mapping to toggle outline
      vim.keymap.set('n', '<leader>to', '<cmd>Outline<CR>', { desc = 'Toggle Outline' })

      require('outline').setup {
        symbol_folding = {
          autofold_depth = 1,
          auto_unfold_hover = true,
        },
        preview_window = {
          auto_preview = true,
        },
      }
    end,
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
}
