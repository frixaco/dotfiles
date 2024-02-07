return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
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
          return vim.fn.executable('make') == 1
        end,
        config = function()
          require('telescope').load_extension('fzf')
        end,
      },
    },
    opts = {},
    config = function()
      require('telescope').setup({
        defaults = {
          layout_config = { prompt_position = 'top' },
          sorting_strategy = 'ascending',
          file_ignore_patterns = { 'node_modules', '.git' },
          mappings = {
            -- i = {
            --   ['<C-u>'] = false,
            --   ['<C-d>'] = false,
            -- },
          },
        },
        extensions = {
          package_info = {},
        },
      })

      -- Telescope live_grep in git root
      -- Function to find the git root directory based on the current buffer's path
      local function find_git_root()
        -- Use the current buffer's path as the starting point for the git search
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir
        local cwd = vim.fn.getcwd()
        -- If the buffer is not associated with a file, return nil
        if current_file == '' then
          current_dir = cwd
        else
          -- Extract the directory from the current file's path
          current_dir = vim.fn.fnamemodify(current_file, ':h')
        end

        -- Find the Git root directory from the current file's path
        local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
        if vim.v.shell_error ~= 0 then
          print('Not a git repository. Searching on current working directory')
          return cwd
        end
        return git_root
      end

      -- Custom live_grep function to search in git root
      local function live_grep_git_root()
        local git_root = find_git_root()
        if git_root then
          require('telescope.builtin').live_grep({
            search_dirs = { git_root },
          })
        end
      end

      vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

      -- See `:help telescope.builtin`
      vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>w', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>fg', require('telescope.builtin').git_files, { desc = 'Find Git Files' })
      vim.keymap.set('n', '<leader>ff', function()
        require('telescope.builtin').find_files({ hidden = true })
      end, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Find Help' })
      vim.keymap.set('n', '<leader>fw', require('telescope.builtin').grep_string, { desc = 'Find Word' })
      vim.keymap.set('n', '<leader>fs', require('telescope.builtin').live_grep, { desc = 'Search by Grep' })
      -- vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<CR>', { desc = '[S]earch by [G]rep on Git Root' })
      vim.keymap.set('n', '<leader>fd', require('telescope.builtin').diagnostics, { desc = 'Find Diagnostics' })
      vim.keymap.set('n', '<leader>fr', require('telescope.builtin').resume, { desc = 'Resume Telescope' })
      -- vim.keymap.set('n', '<leader>fc', require('telescope.builtin').oldfiles, { desc = 'Find Recent' })
      -- vim.keymap.set('n', '<leader>fc', '<CMD>Telescope frecency workspace=CWD<CR>', { desc = 'Find Recent' })
    end,
  },
}
