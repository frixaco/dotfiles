return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      diagnostics = {
        virtual_text = false,
        virtual_lines = true,
        signs = true,
        underline = false,
      },
      ---@type lspconfig.options
      servers = {
        cssls = {},
        html = {},
        tsserver = {},
        eslint = {},
        emmet_language_server = {},
        pyright = {},
        ruff_lsp = {},
        gopls = {
          cmd = { "gopls" },
          filetypes = { "go", "gomod", "gowork", "gotmpl" },
          root_dir = require("lspconfig.server_configurations.gopls").default_config.root_dir,
          settings = {
            gofumpt = true,
            gopls = {
              completeUnimported = true,
              usePlaceholders = true,
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          },
        },
      },
      setup = {
        tailwindcss_language_server = function(_, opts)
          require("tailwindcss").setup({
            server = opts,
            settings = {
              tailwindCSS = {
                experimental = {
                  classRegex = {
                    { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                    { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  },
                },
              },
            },
          })
          return true
        end,

        gopls = function(_, opts)
          -- workaround for gopls not supporting semanticTokensProvider
          -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "gopls" then
              if not client.server_capabilities.semanticTokensProvider then
                local semantic = client.config.capabilities.textDocument.semanticTokens
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = semantic.tokenTypes,
                    tokenModifiers = semantic.tokenModifiers,
                  },
                  range = true,
                }
              end
            end
          end)
          -- end workaround
        end,
      },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "lua-language-server",
        "shellcheck",
        "shfmt",

        "css-lsp",
        "html-lsp",
        "typescript-language-server",
        "eslint-lsp",

        -- c/cpp stuff
        "clangd",
        "clang-format",

        -- python
        "blackd-client",
        "ruff-lsp",
        "pyright",

        -- golang
        "gopls",
      },
    },
  },
}
