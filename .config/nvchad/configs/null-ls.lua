local null_ls = require "null-ls"

local b = null_ls.builtins

local sources = {

  -- webdev stuff
  b.formatting.prettier.with {
    filetypes = {
      "typescript",
      "javascript",
      "javascriptreact",
      "typescriptreact",
      "html",
      "markdown",
      "css",
      "json",
      "graphql",
      "yaml",
    },
  }, -- so prettier works only on these filetypes

  -- Lua
  b.formatting.stylua,

  -- cpp
  b.formatting.clang_format,

  -- python
  b.formatting.black,

  -- yaml
  b.diagnostics.cfn_lint,

  -- go
  b.formatting.gofmt,
}

null_ls.setup {
  debug = true,
  sources = sources,
}
