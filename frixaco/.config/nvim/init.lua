local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- WSL yank support
local clip = '/mnt/c/Windows/System32/clip.exe' -- change this path according to your mount point

if vim.fn.executable(clip) == 1 then
  vim.api.nvim_create_augroup('WSLYank', { clear = true })
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = 'WSLYank',
    callback = function()
      if vim.v.event.operator == 'y' then
        vim.fn.system(clip, vim.fn.getreg('0'))
      end
    end,
  })
end

vim.o.shell = 'fish'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes'
vim.o.scrolloff = 3
vim.g.have_nerd_font = true
vim.o.mouse = 'a'
vim.o.wrap = true
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.confirm = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.api.nvim_set_keymap('n', '<leader>tt', ':CyberdreamToggleMode<CR>', { noremap = true, silent = true })

local opts = { noremap = true, silent = true, desc = 'LSP diagnostic' }

-- Previous error
vim.keymap.set('n', '[e', function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, vim.tbl_extend('force', opts, { desc = 'Previous error' }))

-- Next error
vim.keymap.set('n', ']e', function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, vim.tbl_extend('force', opts, { desc = 'Next error' }))

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

require('lazy').setup({
  defaults = { lazy = true },
  install = { colorscheme = { 'cyberdream' } },
  -- install = { colorscheme = { 'catppuccin' } },
  checker = { enabled = true },
  ui = {
    backdrop = 100,
  },
  spec = {
    -- {
    --   'folke/tokyonight.nvim',
    --   lazy = false,
    --   priority = 1000,
    --   config = function()
    --     vim.cmd.colorscheme('tokyonight-night')
    --   end,
    -- },

    {
      'scottmckendry/cyberdream.nvim',
      lazy = false,
      priority = 1000,
      config = function()
        require('cyberdream').setup({
          variant = 'auto',
          transparent = true,
        })

        vim.cmd.colorscheme('cyberdream')
      end,
    },

    -- {
    --   'catppuccin/nvim',
    --   name = 'catppuccin',
    --   priority = 1000,
    --   lazy = false,
    --   config = function()
    --     vim.cmd.colorscheme('catppuccin-mocha')
    --   end,
    -- },

    {
      'folke/lazydev.nvim',
      event = 'VeryLazy',
      config = function()
        require('lazydev').setup({
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            { path = 'wezterm-types', mods = { 'wezterm' } },
          },
        })
      end,
    },

    {
      'tpope/vim-sleuth',
      event = { 'BufReadPost', 'BufNewFile' },
    },

    {
      'saghen/blink.cmp',
      event = { 'BufReadPre', 'BufNewFile' },
      -- use a release tag to download pre-built binaries
      version = '*',
      opts = {
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono',
        },
        fuzzy = {
          implementation = 'rust',
        },
        completion = {
          --   list = {
          --     selection = {
          --       preselect = true,
          --       auto_insert = true,
          --     },
          --   },
          menu = {
            draw = {
              columns = {
                { 'kind_icon', 'label', 'label_description', 'source_name', gap = 1 },
                -- { 'label_description', gap = 1 },
              },
              treesitter = { 'lsp' },
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
          },
        },
        -- signature = { enabled = true },
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = true,
            },
          },
        },
        sources = {
          default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
          providers = {
            lazydev = {
              name = 'LazyDev',
              module = 'lazydev.integrations.blink',
              -- make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100,
            },
          },
        },
      },
      opts_extend = { 'sources.default' },
    },

    {
      'neovim/nvim-lspconfig',
      event = 'VeryLazy',
      dependencies = {
        {
          'williamboman/mason.nvim',
          opts = {
            ui = {
              backdrop = 100,
            },
          },
        },
        -- 'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        'saghen/blink.cmp',
      },
      opts = {
        inlay_hints = { enabled = false },
        diagnostics = {
          virtual_text = true,
          virtual_lines = true,
          signs = true,
          underline = false,
        },
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
        servers = {
          gopls = {},
          basedpyright = {},
          -- pyright = {},
          ruff = {},
          lua_ls = {},
          ts_ls = {},
          rust_analyzer = {},
          html = {},
          emmet_language_server = {},
          graphql = {},
          cssls = {},
          tailwindcss = {
            -- root_dir = function(fname)
            --   return require('lspconfig').util.root_pattern('.git')(fname) or require('lspconfig').util.path.dirname(fname)
            -- end,
            -- tailwindCSS = {
            --   classAttributes = {
            --     'class',
            --     'className',
            --     'class:list',
            --     'classList',
            --     'ngClass',
            --     'containerClassname',
            --   },
            --   validate = true,
            --   experimental = {
            --     classRegex = {
            --       { 'cva\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
            --       { 'cx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
            --     },
            --   },
            -- },
            -- filetypes = { 'css', 'javascriptreact', 'typescriptreact', 'html' },
          },
        },
      },
      config = function(_, opts)
        -- SIMPLE LspProgress notification
        -- vim.api.nvim_create_autocmd("LspProgress", {
        -- 	---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
        -- 	callback = function(ev)
        -- 		local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        -- 		vim.notify(vim.lsp.status(), "info", {
        -- 			id = "lsp_progress",
        -- 			title = "LSP Progress",
        -- 			opts = function(notif)
        -- 				notif.icon = ev.data.params.value.kind == "end" and " "
        -- 					or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
        -- 			end,
        -- 		})
        -- 	end,
        -- })

        -- ADVANCED LspProgress notification
        ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
        local progress = vim.defaulttable()
        vim.api.nvim_create_autocmd('LspProgress', {
          ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
          callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
            if not client or type(value) ~= 'table' then
              return
            end
            local p = progress[client.id]
            for i = 1, #p + 1 do
              if i == #p + 1 or p[i].token == ev.data.params.token then
                p[i] = {
                  token = ev.data.params.token,
                  msg = ('[%3d%%] %s%s'):format(
                    value.kind == 'end' and 100 or value.percentage or 100,
                    value.title or '',
                    value.message and (' **%s**'):format(value.message) or ''
                  ),
                  done = value.kind == 'end',
                }
                break
              end
            end
            local msg = {} ---@type string[]
            progress[client.id] = vim.tbl_filter(function(v)
              return table.insert(msg, v.msg) or not v.done
            end, p)

            local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
            vim.notify(table.concat(msg, '\n'), vim.log.levels.INFO, {
              id = 'lsp_progress',
              title = client.name,
              opts = function(notif)
                notif.icon = #progress[client.id] == 0 and ' ' or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
              end,
            })
          end,
        })

        require('mason').setup()
        -- NOTE: this causing duplicate Language Servers running each time
        -- require('mason-lspconfig').setup({
        --   ensure_installed = {},
        --   automatic_installation = true,
        -- })
        require('mason-tool-installer').setup({
          ensure_installed = {
            'stylua',
            'prettier',
            'eslint_d',
            'clang-format',
            'goimports',
            'shfmt',
            'shellcheck',
          },
          auto_update = true,
          run_on_start = true,
        })

        local lspconfig = require('lspconfig')
        local util = require('lspconfig.util')

        local on_attach = function(_, bufnr)
          local nnoremap = function(keys, func, desc)
            if desc then
              desc = 'LSP:  ' .. desc
            end
            vim.keymap.set('n', keys, func, { buffer = bufnr, noremap = true, desc = desc })
          end

          nnoremap('<leader>e', vim.diagnostic.open_float, 'Open Floating Diagnostic Message')
          nnoremap('<leader>r', vim.lsp.buf.rename, 'Rename')
          nnoremap('K', vim.lsp.buf.hover, 'Hover Documentation')
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, noremap = true, desc = 'Code Action' })
        end

        for server, config in pairs(opts.servers) do
          -- passing config.capabilities to blink.cmp merges with the capabilities in your
          -- `opts[server].capabilities, if you've defined it
          config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
          config.on_attach = on_attach
          lspconfig[server].setup(config)
        end

        lspconfig.sourcekit.setup({
          on_attach = on_attach,
          capabilities = require('blink.cmp').get_lsp_capabilities({
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
          }),
        })

        local function custom_root_dir(fname)
          -- Check for pyrightconfig.json
          local pyright_config_root = util.root_pattern('pyrightconfig.json')(fname)
          if pyright_config_root then
            return pyright_config_root
          end

          -- Prioritize .git ancestor
          local git_root = vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
          if git_root then
            return git_root
          end

          -- Fallback markers for Python projects
          local fallback_markers = {
            'requirements.txt',
            'pyproject.toml',
            'setup.py', -- Optional: add more markers if relevant
          }
          local marker_root = util.root_pattern(unpack(fallback_markers))(fname)
          if marker_root then
            return marker_root
          end

          -- Ultimate fallback: use the directory of the file itself
          return vim.fs.dirname(fname)
        end

        require('lspconfig').pyright.setup({ root_dir = custom_root_dir })
      end,
    },

    {
      'stevearc/conform.nvim',
      event = { 'BufWritePre' },
      opts = {
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          if disable_filetypes[vim.bo[bufnr].filetype] then
            return nil
          else
            return {
              timeout_ms = 500,
              lsp_format = 'fallback',
            }
          end
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          python = function(bufnr)
            if require('conform').get_formatter_info('ruff_format', bufnr).available then
              return { 'ruff_format' }
            else
              return { 'isort', 'black' }
            end
          end,
          javascript = { 'biome' },
          typescript = { 'biome' },
          javascriptreact = { 'biome' },
          typescriptreact = { 'biome' },
          html = { 'biome', 'prettier' },
          graphql = { 'prettier' },
          yaml = { 'prettier' },
          toml = { 'taplo' },
          json = { 'prettier' },
          jsonc = { 'prettier' },
          go = { 'goimports', 'gofmt' },
          c = { 'clang_format' },
          css = { 'biome', 'prettier' },
          shell = { 'shfmt', 'shellcheck' },
          zsh = { 'shfmt', 'shellcheck' },
          markdown = { 'prettier' },
          swift = { 'swiftformat' },
        },
      },
    },

    {
      'nvim-treesitter/nvim-treesitter',
      event = 'VeryLazy',
      build = ':TSUpdate',
      main = 'nvim-treesitter.configs', -- Sets main module to use for opts
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
      opts = {
        ensure_installed = {
          'c',
          'cpp',
          'html',
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
          'swift',
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
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
      },
    },

    {
      'windwp/nvim-ts-autotag',
      event = 'VeryLazy',
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      config = function()
        require('nvim-ts-autotag').setup({
          opts = {
            -- Defaults
            enable_close = true, -- Auto close tags
            enable_rename = true, -- Auto rename pairs of tags
            enable_close_on_slash = true, -- Auto close on trailing </
          },
        })
      end,
    },

    {
      'nvim-treesitter/nvim-treesitter-context',
      event = 'VeryLazy',
      config = function()
        require('treesitter-context').setup({
          enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
          multiwindow = false, -- Enable multiwindow support.
          max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
          min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
          line_numbers = true,
          multiline_threshold = 20, -- Maximum number of lines to show for a single context
          trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
          mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
          -- Separator between context and content. Should be a single character string, like '-'.
          -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
          separator = nil,
          zindex = 20, -- The Z-index of the context window
          on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        })
      end,
    },

    {
      'folke/snacks.nvim',
      -- priority = 1000,
      -- lazy = false,
      ---@type snacks.Config
      opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        notifier = { enabled = true },
        lazygit = { enabled = true },
        -- scroll = { enabled = true },
        statuscolumn = { enabled = true },
        picker = {
          layout = {
            layout = {
              backdrop = false,
              -- border = 'none',
            },
          },
          enabled = true,
          sources = {
            explorer = {
              ignored = true,
              hidden = true,
              follow = true,
            },
            files = {
              ignored = false,
              show_empty = true,
              hidden = true,
              follow = true,
            },
          },
          exclude = {
            'node_modules',
            '.git',
            '.venv',
            '.next',
          },
        },
        styles = {},
      },
      keys = {
        -- {
        --   '<leader>b',
        --   function()
        --     Snacks.explorer()
        --   end,
        --   desc = 'File Explorer',
        -- },
        {
          '<leader>gg',
          function()
            Snacks.lazygit()
          end,
          desc = 'Lazygit',
        },
        {
          '<leader><space>',
          function()
            Snacks.picker.smart()
          end,
          desc = 'Smart Find Files',
        },

        {
          '<leader>p',
          function()
            Snacks.picker.files()
          end,
          desc = 'Find Files',
        },
        {
          '<leader>l',
          function()
            Snacks.picker.lines()
          end,
          desc = 'Grep Buffer',
        },
        {
          '<leader>fg',
          function()
            Snacks.picker.grep()
          end,
          desc = 'Grep Files',
        },
        {
          '<leader>fh',
          function()
            Snacks.picker.help()
          end,
          desc = 'Help Pages',
        },
        {
          'gd',
          function()
            Snacks.picker.lsp_definitions()
          end,
          desc = 'Goto Definition',
        },
        {
          'gr',
          function()
            Snacks.picker.lsp_references()
          end,
          nowait = true,
          desc = 'References',
        },
        {
          'gI',
          function()
            Snacks.picker.lsp_implementations()
          end,
          desc = 'Goto Implementation',
        },
        {
          'gy',
          function()
            Snacks.picker.lsp_type_definitions()
          end,
          desc = 'Goto T[y]pe Definition',
        },
      },
    },

    {
      'lewis6991/gitsigns.nvim',
      event = 'VeryLazy',
      opts = {
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end)

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end)

          -- Actions
          map('n', '<leader>hs', gitsigns.stage_hunk)
          map('n', '<leader>hr', gitsigns.reset_hunk)

          map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)

          map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)

          map('n', '<leader>hS', gitsigns.stage_buffer)
          map('n', '<leader>hR', gitsigns.reset_buffer)
          map('n', '<leader>hp', gitsigns.preview_hunk)
          map('n', '<leader>hi', gitsigns.preview_hunk_inline)

          map('n', '<leader>hb', function()
            gitsigns.blame_line({ full = true })
          end)

          map('n', '<leader>hd', gitsigns.diffthis)

          map('n', '<leader>hD', function()
            gitsigns.diffthis('~')
          end)

          map('n', '<leader>hQ', function()
            gitsigns.setqflist('all')
          end)
          map('n', '<leader>hq', gitsigns.setqflist)

          -- Toggles
          map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
          map('n', '<leader>tw', gitsigns.toggle_word_diff)

          -- Text object
          map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
        end,
      },
    },

    {
      'otavioschwanck/arrow.nvim',
      event = 'VeryLazy',
      dependencies = {},
      opts = {
        show_icons = true,
        leader_key = ';',
        buffer_leader_key = 'm',
      },
    },

    {
      'folke/todo-comments.nvim',
      event = 'VeryLazy',
      opts = {},
      keys = {
        {
          '<leader>st',
          function()
            Snacks.picker.todo_comments()
          end,
          desc = 'Todo',
        },
      },
    },

    {
      'echasnovski/mini.indentscope',
      event = 'VeryLazy',
      version = false,
      config = function()
        local no_indent_animation = require('mini.indentscope').gen_animation.none()
        require('mini.indentscope').setup({
          draw = {
            animation = no_indent_animation,
          },
          symbol = '│',
        })
      end,
    },

    {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = true,
    },

    {
      'nvim-lualine/lualine.nvim',
      event = 'VeryLazy',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        require('lualine').setup({
          options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '│', right = '│' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = {
              statusline = { 'snacks_dashboard' },
              winbar = {},
            },
            ignore_focus = {},
            always_divide_middle = true,
            always_show_tabline = true,
            globalstatus = true,
            refresh = {
              statusline = 100,
              tabline = 100,
              winbar = 100,
            },
          },
          sections = {
            lualine_a = {
              {
                'mode',
                fmt = function(str)
                  return str:sub(1, 1):upper()
                end,
              },
            },
            lualine_b = {
              {
                'filename',
                show_modified_status = true,
                use_mode_colors = true,
                path = 1, -- 0: Just the filename
                -- 1: Relative path
                -- 2: Absolute path
                -- 3: Absolute path, with tilde as the home directory
                -- 4: Filename and parent dir, with tilde as the home directory
              },
            },
            lualine_c = { 'diagnostics' },
            lualine_x = {
              {
                'searchcount',
                maxcount = 999,
                timeout = 500,
              },
              { 'selectioncount' },
              'fileformat',
            },
            lualine_y = {},
            lualine_z = {
              'branch',
            },
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
          },
          tabline = {},
          winbar = {},
          inactive_winbar = {},
          extensions = {},
        })
      end,
    },

    -- { "echasnovski/mini.statusline", version = false, opts = {} },

    {
      'mikavilpas/yazi.nvim',
      event = 'VeryLazy',
      dependencies = {
        -- check the installation instructions at
        -- https://github.com/folke/snacks.nvim
        'folke/snacks.nvim',
      },
      keys = {
        -- 👇 in this section, choose your own keymappings!
        {
          '<leader>b',
          mode = { 'n', 'v' },
          '<cmd>Yazi<cr>',
          desc = 'Open yazi at the current file',
        },
        -- {
        --   -- Open in the current working directory
        --   '<leader>cw',
        --   '<cmd>Yazi cwd<cr>',
        --   desc = "Open the file manager in nvim's working directory",
        -- },
        -- {
        --   '<c-up>',
        --   '<cmd>Yazi toggle<cr>',
        --   desc = 'Resume the last yazi session',
        -- },
      },
      ---@type YaziConfig | {}
      opts = {
        -- if you want to open yazi instead of netrw, see below for more info
        open_for_directories = true,
        keymaps = {
          show_help = '<f1>',
        },
      },
      -- 👇 if you use `open_for_directories=true`, this is recommended
      init = function()
        -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
        -- vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
      end,
    },

    {
      'catgoose/nvim-colorizer.lua',
      event = 'VeryLazy',
      opts = { -- set to setup table
        lazy_load = true,
        user_default_options = {
          RRGGBBAA = true, -- #RRGGBBAA hex codes
          AARRGGBB = true, -- 0xAARRGGBB hex codes
          rgb_fn = true, -- CSS rgb() and rgba() functions
          hsl_fn = true, -- CSS hsl() and hsla() functions
          css = true, -- Enable all CSS *features*:
          -- names, RGB, RGBA, RRGGBB, RRGGBBAA, AARRGGBB, rgb_fn, hsl_fn
          css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
          -- Tailwind colors.  boolean|'normal'|'lsp'|'both'.  True sets to 'normal'
          tailwind = true, -- Enable tailwind colors
          tailwind_opts = { -- Options for highlighting tailwind names
            update_names = true, -- When using tailwind = 'both', update tailwind names from LSP results.  See tailwind section
          },
        },
      },
    },

    {
      'MeanderingProgrammer/render-markdown.nvim',
      event = 'VeryLazy',
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      config = function()
        pcall(function()
          require('render-markdown').setup()
        end)

        function ToggleCheckbox()
          local line = vim.api.nvim_get_current_line()
          local checkbox_pattern = '^%s*%- %[(.)%]'
          local status = line:match(checkbox_pattern)

          if status == ' ' then
            line = line:gsub(checkbox_pattern, '- [x]')
          elseif status == 'x' or status == 'X' then
            line = line:gsub(checkbox_pattern, '- [ ]')
          else
            return
          end

          vim.api.nvim_set_current_line(line)
        end

        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'markdown',
          callback = function()
            vim.api.nvim_buf_set_keymap(0, 'n', '<Tab>', ':lua ToggleCheckbox()<CR>', { noremap = true, silent = true })
          end,
        })
      end,
    },

    {
      'dmtrKovalenko/fff.nvim',
      build = 'cargo build --release',
      -- or if you are using nixos
      -- build = "nix run .#release",
      opts = {
        -- pass here all the options
      },
      keys = {
        {
          'ff', -- try it if you didn't it is a banger keybinding for a picker
          function()
            require('fff').find_files() -- or find_in_git_root() if you only want git files
          end,
          desc = 'Open file picker',
        },
      },
    },
  },
})
