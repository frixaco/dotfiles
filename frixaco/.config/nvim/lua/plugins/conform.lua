return {
  {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          python = function(bufnr)
            if require('conform').get_formatter_info('ruff_format', bufnr).available then
              return { 'ruff_format' }
            else
              return { 'isort', 'black' }
            end
          end,
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          javascriptreact = { 'prettier' },
          typescriptreact = { 'prettier' },
          graphql = { 'prettier' },
          yaml = { 'prettier' },
          toml = { 'taplo' },
          json = { 'prettier' },
          jsonc = { 'prettier' },
          go = { 'goimports', 'gofmt' },
          -- c = { 'clang_format' },
          html = { 'prettier' },
          css = { 'prettier' },
          shell = { 'shfmt', 'shellcheck' },
          zsh = { 'shfmt', 'shellcheck' },
          markdown = { 'prettier' },
        },
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 500,
        },
        notify_on_error = false,
        formatters = {
          shfmt = {
            prepend_args = { '-i', '2', '-ci' },
          },
        },
      })
    end,
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
