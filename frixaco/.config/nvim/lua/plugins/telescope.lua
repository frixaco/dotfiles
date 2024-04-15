return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    tag = '0.1.6',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable('make') == 1
        end,
        config = function()
          require('telescope').load_extension('fzf')
        end,
      },
      -- {
      --   'nvim-telescope/telescope-file-browser.nvim',
      --   keys = {
      --     {
      --       '<leader>fm',
      --       mode = { 'n' },
      --       ':Telescope file_browser path=%:p:h select_buffer=true<CR>',
      --       desc = 'Toggle NvimTree',
      --       silent = true,
      --       noremap = true,
      --     },
      --   },
      --   config = function()
      --     require('telescope').load_extension('file_browser')
      --   end,
      -- },
      {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
          require('telescope').load_extension('ui-select')
        end,
      },
    },
    config = function()
      local state = require('telescope.state')
      local action_state = require('telescope.actions.state')
      local slow_scroll = function(prompt_bufnr, direction)
        local previewer = action_state.get_current_picker(prompt_bufnr).previewer
        local status = state.get_status(prompt_bufnr)

        -- Check if we actually have a previewer and a preview window
        if type(previewer) ~= 'table' or previewer.scroll_fn == nil or status.preview_win == nil then
          return
        end

        previewer:scroll_fn(1 * direction)
      end

      require('telescope').setup({
        defaults = {
          layout_config = { prompt_position = 'top' },
          sorting_strategy = 'ascending',
          file_ignore_patterns = { 'node_modules', '.git/', '.venv', '.next' },
          mappings = {
            i = {
              ['<C-j>'] = function(bufnr)
                slow_scroll(bufnr, 1)
              end,
              ['<C-k>'] = function(bufnr)
                slow_scroll(bufnr, -1)
              end,
              ['<C-w>'] = 'which_key',
            },
          },
        },
        extensions = {
          package_info = {},
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or "ignore_case" or "respect_case", the default case_mode is "smart_case"
          },
          file_browser = {
            theme = 'catppuccin',
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
              ['i'] = {
                -- your custom insert mode mappings
              },
              ['n'] = {
                -- your custom normal mode mappings
              },
            },
          },
          ['ui-select'] = {
            require('telescope.themes').get_dropdown({
              -- even more opts
            }),

            -- pseudo code / specification for writing custom displays, like the one
            -- for "codeactions"
            -- specific_opts = {
            --   [kind] = {
            --     make_indexed = function(items) -> indexed_items, width,
            --     make_displayer = function(widths) -> displayer
            --     make_display = function(displayer) -> function(e)
            --     make_ordinal = function(e) -> string
            --   },
            --   -- for example to disable the custom builtin "codeactions" display
            --      do the following
            --   codeactions = false,
            -- }
          },
        },
      })

      -- local function live_grep_git_root()
      --   local git_root = utils.find_git_root()
      --   if git_root then
      --     require('telescope.builtin').live_grep({
      --       search_dirs = { git_root },
      --     })
      --   end
      -- end
      -- vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
      -- vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<CR>', { desc = '[S]earch by [G]rep on Git Root' })
    end,
    keys = {
      {
        '<space><space>',
        mode = { 'n' },
        function()
          require('telescope.builtin').buffers()
        end,
        desc = 'Find Buffers',
      },

      {
        '<leader>\\',
        mode = { 'n' },
        function()
          require('telescope.builtin').current_buffer_fuzzy_find()
        end,
      },

      {
        '<leader>p',
        mode = { 'n' },
        function()
          require('telescope.builtin').find_files({
            hidden = true,
            follow = true,
          })
        end,
        desc = 'Find Files',
      },

      {
        '<leader>fh',
        mode = { 'n' },
        function()
          require('telescope.builtin').help_tags()
        end,
        desc = 'Find Help',
      },

      {
        '<leader>fg',
        mode = { 'n' },
        function()
          require('telescope.builtin').live_grep({
            additional_args = function()
              return { '--hidden', '--follow' }
            end,
          })
        end,
        desc = 'Search by Grep',
      },

      {
        '<leader>fd',
        mode = { 'n' },
        function()
          require('telescope.builtin').diagnostics()
        end,
        desc = 'Find Diagnostics',
      },

      {
        '<leader>fr',
        mode = { 'n' },
        function()
          require('telescope.builtin').resume()
        end,
        desc = 'Resume Telescope',
      },
    },
  },
}
