return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'VeryLazy',
    dependencies = {
      'windwp/nvim-ts-autotag',
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
    config = function()
      -- local function ts_disable(_, bufnr)
      --   return vim.api.nvim_buf_line_count(bufnr) > 5000
      -- end

      -- See `:help nvim-treesitter`
      require('nvim-treesitter.configs').setup({
        -- Enable `nvim-ts-autotag`
        autotag = {
          enable = true,
          enable_rename = true,
          enable_close = true,
          enable_close_on_slash = false,
        },

        modules = {},

        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = {
          'c',
          'cpp',
          'css',
          'xml',
          'go',
          'lua',
          'python',
          'astro',
          'svelte',
          'rust',
          'hcl',
          'tsx',
          'javascript',
          'typescript',
          'vimdoc',
          'vim',
          'bash',
          'yaml',
          'graphql',
          'toml',
          'regex',
          'json',
          'jsonc',
          'markdown',
          'markdown_inline',
          'sql',
          'git_config',
          'gitignore',
        },

        sync_install = false,
        ignore_install = {},

        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = true,

        highlight = {
          enable = true,

          -- disable = function(lang, bufnr)
          --   return ts_disable(lang, bufnr)
          -- end,
          -- disable = function(lang, buf)
          --   local max_filesize = 3000 * 1024 -- 100 KB
          --   local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          --   if ok and stats and stats.size > max_filesize then
          --     return true
          --   end
          -- end,
          disable = { 'c', 'cpp' },
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            -- init_selection = '<c-space>',
            -- node_incremental = '<c-space>',
            -- scope_incremental = '<c-s>',
            -- node_decremental = '<M-space>',
          },
        },
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
              -- You can also use captures from other query groups like `locals.scm`
              ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V', -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true or false
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              -- [']m'] = '@function.outer',
              -- [']]'] = { query = '@class.outer', desc = 'Next class start' },
              -- --
              -- -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
              -- [']o'] = '@loop.*',
              -- -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
              -- --
              -- -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
              -- -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
              -- [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
              -- [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
            },
            goto_next_end = {
              -- [']M'] = '@function.outer',
              -- [']['] = '@class.outer',
            },
            goto_previous_start = {
              -- ['[m'] = '@function.outer',
              -- ['[['] = '@class.outer',
            },
            goto_previous_end = {
              -- ['[M'] = '@function.outer',
              -- ['[]'] = '@class.outer',
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
              -- [']d'] = '@conditional.outer',
            },
            goto_previous = {
              -- ['[d'] = '@conditional.outer',
            },
          },
        },
      })

      vim.o.foldenable = false
      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
    end,
  },
}
