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
          'go',
          'lua',
          'python',
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
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              -- ['aa'] = '@parameter.outer',
              -- ['ia'] = '@parameter.inner',
              -- ['af'] = '@function.outer',
              -- ['if'] = '@function.inner',
              -- ['ac'] = '@class.outer',
              -- ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              -- [']m'] = '@function.outer',
              -- [']n'] = '@class.outer',
            },
            goto_next_end = {
              --   [']M'] = '@function.outer',
              -- [']['] = '@class.outer',
            },
            goto_previous_start = {
              -- ['[m'] = '@function.outer',
              -- ['[n'] = '@class.outer',
            },
            goto_previous_end = {
              -- ['[M'] = '@function.outer',
              -- ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              -- ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              -- ['<leader>A'] = '@parameter.inner',
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
