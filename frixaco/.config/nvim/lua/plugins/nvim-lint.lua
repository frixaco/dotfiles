return {
  {
    'mfussenegger/nvim-lint',
    event = 'VeryLazy',
    config = function()
      require('lint').linters_by_ft = {
        javascript = { 'eslint' },
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },
        javascriptreact = { 'eslint' },
      }

      -- Run nvim-lint on save
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          pcall(require, 'lint.try_lint')
        end,
      })
    end,
  },
}
