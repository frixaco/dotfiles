return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        cssls = {},
        html = {},
        tsserver = {},
        tailwindcss = {},
        eslint = {},
        emmet_language_server = {},
        prettierd = {},
        pyright = {},
        ruff_lsp = {},
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
        "prettierd",
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
