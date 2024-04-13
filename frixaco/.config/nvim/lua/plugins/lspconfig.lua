return {
  -- {
  --   'WhoIsSethDaniel/mason-tool-installer.nvim',
  --   opts = {
  --
  --     -- a list of all tools you want to ensure are installed upon
  --     -- start
  --     ensure_installed = {
  --       'stylua',
  --       'isort',
  --       'black',
  --       'prettier',
  --       'clang-format',
  --       'goimports',
  --       'shfmt',
  --       'shellcheck',
  --     },
  --
  --     -- if set to true this will check each tool for updates. If updates
  --     -- are available the tool will be updated. This setting does not
  --     -- affect :MasonToolsUpdate or :MasonToolsInstall.
  --     -- Default: false
  --     auto_update = false,
  --
  --     -- automatically install / update on startup. If set to false nothing
  --     -- will happen on startup. You can use :MasonToolsInstall or
  --     -- :MasonToolsUpdate to install tools and check for updates.
  --     -- Default: true
  --     run_on_start = true,
  --
  --     -- set a delay (in ms) before the installation starts. This is only
  --     -- effective if run_on_start is set to true.
  --     -- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
  --     -- Default: 0
  --     start_delay = 3000, -- 3 second delay
  --
  --     -- Only attempt to install if 'debounce_hours' number of hours has
  --     -- elapsed since the last time Neovim was started. This stores a
  --     -- timestamp in a file named stdpath('data')/mason-tool-installer-debounce.
  --     -- This is only relevant when you are using 'run_on_start'. It has no
  --     -- effect when running manually via ':MasonToolsInstall' etc....
  --     -- Default: nil
  --     debounce_hours = 5, -- at least 5 hours between attempts to install/update
  --   },
  -- },

  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    build = ':MasonUpdate',
    opts = {
      ensure_installed = {
        'stylua',
        'isort',
        'black',
        'prettier',
        'clang-format',
        'goimports',
        'shfmt',
        'shellcheck',
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require('mason-registry')
      mr:on('package:install:success', function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require('lazy.core.handler.event').trigger({
            event = 'FileType',
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
      { 'folke/neodev.nvim', opts = {} },

      'williamboman/mason.nvim',
      -- 'mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            window = {
              winblend = 0,
            },
          },
        },
      },

      {
        'hrsh7th/nvim-cmp',
        dependencies = {
          'L3MON4D3/LuaSnip', -- Snippet Engine &
          'saadparwaiz1/cmp_luasnip', -- its associated nvim-cmp source
          'hrsh7th/cmp-nvim-lsp', -- Adds LSP completion capabilities
          'hrsh7th/cmp-cmdline',
          -- 'hrsh7th/cmp-buffer',
        },
      },
    },
    opts = {
      inlay_hints = { enabled = true },
      diagnostics = {
        virtual_text = true,
        virtual_lines = true,
        signs = true,
        underline = false,
      },
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = false,
          },
        },
      },
      servers = {
        clangd = {},
        gopls = {},
        pyright = {},
        ruff_lsp = {},
        eslint = {},
        tflint = {},
        terraformls = {},
        rust_analyzer = {},
        tsserver = {},
        svelte = {},
        html = {},
        emmet_language_server = {},
        graphql = {},
        tailwindcss = {
          root_dir = function(fname)
            return require('lspconfig').util.root_pattern('.git')(fname) or require('lspconfig').util.path.dirname(fname)
          end,
          tailwindCSS = {
            classAttributes = {
              'class',
              'className',
              'class:list',
              'classList',
              'ngClass',
              'containerClassname',
            },
            validate = true,
            experimental = {
              classRegex = {
                { 'cva\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
                { 'cx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              },
            },
          },
        },
        jsonls = {
          json = {
            schemas = {
              {
                fileMath = { 'package.json' },
                url = 'https://json.schemastore.org/package.json',
              },
              {
                fileMatch = { 'tsconfig.json', 'tsconfig.*.json' },
                url = 'https://json.schemastore.org/tsconfig.json',
              },
              {
                fileMath = {
                  '.prettierrc',
                  '.prettierrc.json',
                  'prettier.config.json',
                },
                url = 'https://json.schemastore.org/prettierrc.json',
              },
              {
                fileMath = { '.eslintrc', '.eslintrc.json' },
                url = 'https://json.schemastore.org/eslintrc.json',
              },
              {
                fileMatch = { 'pyrightconfig.json' },
                url = 'https://raw.githubusercontent.com/microsoft/pyright/main/packages/vscode-pyright/schemas/pyrightconfig.schema.json',
              },
            },
          },
        },
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      },
    },
    config = function(_, opts)
      local servers = opts.servers

      local on_attach = function(_, bufnr)
        local nnoremap = function(keys, func, desc)
          if desc then
            desc = 'LSP:  ' .. desc
          end
          vim.keymap.set('n', keys, func, { buffer = bufnr, noremap = true, desc = desc })
        end

        nnoremap('<leader>e', vim.diagnostic.goto_prev, 'Go to previous diagnostic message')
        nnoremap('<leader>n', vim.diagnostic.goto_next, 'Go to next diagnostic message')
        nnoremap('<leader>E', vim.diagnostic.open_float, 'Open floating diagnostic message')
        nnoremap('<leader>q', vim.diagnostic.setloclist, 'Open diagnostics list')

        nnoremap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nnoremap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        nnoremap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [d]efinition')
        nnoremap('gD', require('telescope.builtin').lsp_type_definitions, '[G]oto [D]eclaration')
        nnoremap('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        nnoremap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        nnoremap('K', vim.lsp.buf.hover, 'Hover documentation')
        -- nnoremap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
        nnoremap('<space>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        nnoremap('<space>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        nnoremap('<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, 'List [W]orkspace [F]olders')
        nnoremap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        nnoremap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
        -- nnoremap('<leader>f', function()
        --   vim.lsp.buf.format({ async = true })
        -- end, 'Format current buffer')
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, noremap = true, desc = 'LSP:  [C]ode [A]ction' })
      end

      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local function setup(server_name)
        local server_opts = {
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = (servers[server_name] or {}).filetypes,
        }
        lspconfig[server_name].setup(server_opts)
      end

      local mlsp = require('mason-lspconfig')
      local available = mlsp.get_available_servers()

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(available, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = ensure_installed,
        automatic_installation = true,
      })
      require('mason-lspconfig').setup_handlers({ setup })

      require('lspconfig').gdscript.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'gd', 'gdscript', 'gdscript3' },
      })

      -- Full build should be installed, via Cargo e.g.
      require('lspconfig').taplo.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'toml' },
      })

      -- Autocompletion
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      luasnip.config.setup({})

      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete({}),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      })
      -- cmp.setup.cmdline('/', {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = {
      --     { name = 'buffer' },
      --   },
      -- })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          {
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' },
            },
          },
        }),
      })
    end,
  },
}
