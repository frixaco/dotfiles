vim.loader.enable()

-- Must be set before plugins/keymaps
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- nvim-tree requires netrw disabled early
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- WSL clipboard provider should be registered early
pcall(function()
  require('wsl').setup()
end)

--------------------------------------------------------------------------------
-- PLUGINS (vim.pack.add)
--------------------------------------------------------------------------------

if not vim.pack or type(vim.pack.add) ~= 'function' then
  vim.notify('This config requires Neovim with `vim.pack` support (0.12+).', vim.log.levels.ERROR)
  return
end

-- Post-install/update hooks for specific plugins.
-- NOTE: Hooks must be registered before `vim.pack.add()` for first-install.
local pack_hooks_group = vim.api.nvim_create_augroup('pack-hooks', { clear = true })
local function is_repo(spec, needle)
  return type(spec) == 'table' and type(spec.src) == 'string' and spec.src:find(needle, 1, true) ~= nil
end
vim.api.nvim_create_autocmd('PackChanged', {
  group = pack_hooks_group,
  desc = 'Run post-install/update hooks for selected plugins',
  callback = function(ev)
    local data = ev.data or {}
    local spec = data.spec or {}
    local kind = data.kind

    if kind == 'delete' then
      return
    end

    local is_treesitter = spec.name == 'nvim-treesitter' or is_repo(spec, 'nvim-treesitter/nvim-treesitter')
    if is_treesitter and (kind == 'install' or kind == 'update') then
      pcall(vim.cmd.packadd, 'nvim-treesitter')
      vim.cmd('silent! TSUpdate')
      return
    end

    local is_fff = spec.name == 'fff.nvim' or spec.name == 'fff' or is_repo(spec, 'dmtrKovalenko/fff.nvim')
    if is_fff and (kind == 'install' or kind == 'update') then
      pcall(vim.cmd.packadd, 'fff.nvim')
      pcall(vim.cmd.packadd, 'fff')
      local ok, err = pcall(function()
        require('fff.download').download_or_build_binary()
      end)
      if not ok then
        vim.notify(('fff.nvim post-%s hook failed: %s'):format(kind, tostring(err)), vim.log.levels.WARN)
      end
    end
  end,
})

local ok_pack_add, pack_add_err = pcall(vim.pack.add, {
  -- Colorscheme
  { src = 'https://github.com/scottmckendry/cyberdream.nvim' },

  -- Core utilities
  { src = 'https://github.com/nvim-lua/plenary.nvim' }, -- Dependency for many plugins
  { src = 'https://github.com/tpope/vim-sleuth' }, -- Auto-detect indent
  { src = 'https://github.com/windwp/nvim-autopairs' },
  { src = 'https://github.com/folke/todo-comments.nvim' },
  { src = 'https://github.com/echasnovski/mini.indentscope' },
  { src = 'https://github.com/catgoose/nvim-colorizer.lua' },
  { src = 'https://github.com/jiaoshijie/undotree' },

  -- Git
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },

  -- Formatting
  { src = 'https://github.com/stevearc/conform.nvim' },

  -- Statusline
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },

  -- Treesitter
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  -- { src = 'https://github.com/windwp/nvim-ts-autotag' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },

  -- LSP config data
  { src = 'https://github.com/neovim/nvim-lspconfig' },

  -- Completion
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1.10.2' },

  -- Picker & utilities
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },

  -- File picker
  { src = 'https://github.com/dmtrKovalenko/fff.nvim' },
})
if not ok_pack_add then
  vim.notify(('vim.pack.add failed: %s'):format(tostring(pack_add_err)), vim.log.levels.ERROR)
end

-- Convenience command if you ever need to (re)build fff.nvim manually.
vim.api.nvim_create_user_command('FffSync', function()
  pcall(vim.cmd.packadd, 'fff.nvim')
  pcall(vim.cmd.packadd, 'fff')
  local ok, err = pcall(function()
    require('fff.download').download_or_build_binary()
  end)
  if not ok then
    vim.notify(('FffSync failed: %s'):format(tostring(err)), vim.log.levels.ERROR)
  end
end, { desc = 'Download/build fff.nvim binary' })

--------------------------------------------------------------------------------
-- BASIC OPTIONS
--------------------------------------------------------------------------------

vim.o.clipboard = 'unnamedplus'
vim.o.termguicolors = true

if vim.fn.executable('fish') == 1 then
  vim.o.shell = 'fish'
end
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes:2'
vim.o.scrolloff = 3
vim.o.mouse = 'a'
vim.o.wrap = true
vim.o.linebreak = true
vim.o.showmode = false
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

--------------------------------------------------------------------------------
-- KEYMAPS
--------------------------------------------------------------------------------

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>tt', '<cmd>CyberdreamToggleMode<CR>', { desc = 'Toggle theme mode', silent = true })

-- Diagnostic navigation
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = 'Previous diagnostic' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = 'Next diagnostic' })

vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Previous error' })

vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Next error' })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic' })
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { desc = 'LSP: Rename' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP: Goto definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'LSP: References' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'LSP: Hover documentation' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP: Code action' })

--------------------------------------------------------------------------------
-- AUTOCMDS
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.hl_op()
  end,
})

--------------------------------------------------------------------------------
-- PLUGIN CONFIGS (wrapped in pcall for first-run safety)
--------------------------------------------------------------------------------

-- Helper to safely require and setup plugins
local function setup(mod, opts)
  local ok, m = pcall(require, mod)
  if ok and m.setup then
    m.setup(opts)
  end
  return ok, m
end

-- Colorscheme
local cyberdream_ok = setup('cyberdream', { variant = 'auto', transparent = true })
if cyberdream_ok then
  vim.cmd.colorscheme('cyberdream')
end

-- Simple plugins
setup('nvim-autopairs', {})
setup('todo-comments', {})
setup('undotree', {})
vim.keymap.set('n', '<leader>u', function()
  require('undotree').toggle()
end, { desc = 'Toggle Undotree' })

-- mini.indentscope
local indent_ok, indentscope = pcall(require, 'mini.indentscope')
if indent_ok then
  indentscope.setup({
    draw = { animation = indentscope.gen_animation.none() },
    symbol = '│',
  })
end

-- nvim-colorizer
setup('colorizer', {
  lazy_load = true,
  user_default_options = {
    RRGGBBAA = true,
    AARRGGBB = true,
    rgb_fn = true,
    hsl_fn = true,
    css = true,
    css_fn = true,
    tailwind = true,
    tailwind_opts = { update_names = true },
  },
})

-- nvim-tree
local nvim_tree_ok = setup('nvim-tree', {
  sort_by = 'case_sensitive',
  view = {
    width = 35,
    preserve_window_proportions = true,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  update_focused_file = {
    enable = true,
    update_root = false,
  },
})
if nvim_tree_ok then
  vim.keymap.set('n', '<leader>ft', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle tree', silent = true })
  vim.keymap.set('n', '<leader>n', '<cmd>NvimTreeFindFile<CR>', { desc = 'Reveal file in tree', silent = true })
end

-- gitsigns
local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
if gitsigns_ok then
  gitsigns.setup({
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buf = bufnr
        vim.keymap.set(mode, l, r, opts)
      end
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gs.nav_hunk('next')
        end
      end)
      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gs.nav_hunk('prev')
        end
      end)
      map('n', '<leader>hs', gs.stage_hunk)
      map('n', '<leader>hr', gs.reset_hunk)
      map('v', '<leader>hs', function()
        gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end)
      map('v', '<leader>hr', function()
        gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end)
      map('n', '<leader>hS', gs.stage_buffer)
      map('n', '<leader>hR', gs.reset_buffer)
      map('n', '<leader>hp', gs.preview_hunk)
      map('n', '<leader>hi', gs.preview_hunk_inline)
      map('n', '<leader>hb', function()
        gs.blame_line({ full = true })
      end)
      map('n', '<leader>hd', gs.diffthis)
      map('n', '<leader>hD', function()
        gs.diffthis('~')
      end)
      map('n', '<leader>hQ', function()
        gs.setqflist('all')
      end)
      map('n', '<leader>hq', gs.setqflist)
      map('n', '<leader>tb', gs.toggle_current_line_blame)
      map('n', '<leader>tw', gs.toggle_word_diff)
      map({ 'o', 'x' }, 'ih', gs.select_hunk)
    end,
  })
end

-- conform
local conform_ok, conform = pcall(require, 'conform')
if conform_ok then
  conform.setup({
    format_on_save = false,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format' },
      javascript = { 'oxfmt' },
      typescript = { 'oxfmt' },
      javascriptreact = { 'oxfmt' },
      typescriptreact = { 'oxfmt' },
      html = { 'oxfmt' },
      graphql = { 'oxfmt' },
      yaml = { 'oxfmt' },
      toml = { 'taplo' },
      json = { 'oxfmt' },
      jsonc = { 'oxfmt' },
      go = { 'goimports', 'gofmt' },
      c = { 'clang_format' },
      css = { 'oxfmt' },
      shell = { 'shfmt', 'shellcheck' },
      zsh = { 'shfmt', 'shellcheck' },
      markdown = { 'oxfmt' },
      rust = { 'rustfmt', lsp_format = 'fallback' },
    },
  })

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
    conform.format({ async = true, lsp_format = 'fallback' })
  end, { desc = 'Format buffer/range' })
end

-- lualine
setup('lualine', {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '│', right = '│' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = { statusline = { 'dashboard' } },
    globalstatus = true,
    refresh = { statusline = 100, tabline = 100, winbar = 100 },
  },
  sections = {
    lualine_a = { {
      'mode',
      fmt = function(str)
        return str:sub(1, 1):upper()
      end,
    } },
    lualine_b = { { 'filename', show_modified_status = true, use_mode_colors = true, path = 1 } },
    lualine_c = { 'diagnostics' },
    lualine_x = { { 'searchcount', maxcount = 999, timeout = 500 }, { 'selectioncount' }, 'fileformat' },
    lualine_y = {},
    lualine_z = { 'branch' },
  },
})

-- treesitter (new nvim-treesitter is just a parser installer; highlighting is built-in on 0.12+)
setup('nvim-treesitter', {})
local ts_parsers = {
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
  'vimdoc',
  'vim',
  'bash',
  'yaml',
  'graphql',
  'toml',
  'regex',
  'json',
  'markdown',
  'markdown_inline',
  'sql',
  'git_config',
  'gitignore',
}

local function ts_missing_parsers()
  local ok, ts_config = pcall(require, 'nvim-treesitter.config')
  if not ok then
    return {}
  end

  local installed = {}
  for _, p in ipairs(ts_config.get_installed('parsers')) do
    installed[p] = true
  end

  return vim.tbl_filter(function(p)
    return not installed[p]
  end, ts_parsers)
end

local function ts_install_missing_in_background()
  if vim.env.NVIM_TS_INSTALL_CHILD == '1' then
    return false
  end

  local missing = ts_missing_parsers()
  if #missing == 0 then
    return false
  end

  local lua_cmd = string.format(
    "local ok, install = pcall(require, 'nvim-treesitter.install'); if ok then install.install(vim.json.decode(%q), { summary = true }) end",
    vim.json.encode(missing)
  )

  vim.system({ vim.v.progpath, '--headless', '+lua ' .. lua_cmd, '+qa' }, {
    detach = true,
    env = { NVIM_TS_INSTALL_CHILD = '1' },
  })

  return true
end

-- Install missing parsers on startup via detached headless Neovim.
-- Keeps current session responsive and avoids cmdline takeover.
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('ts-ensure-installed', { clear = true }),
  callback = function()
    ts_install_missing_in_background()
  end,
})

vim.api.nvim_create_user_command('TSInstallMissingBg', function()
  if ts_install_missing_in_background() then
    vim.notify('Treesitter parser install started in background', vim.log.levels.INFO)
  else
    vim.notify('No missing Treesitter parsers', vim.log.levels.INFO)
  end
end, { desc = 'Install missing Treesitter parsers in detached headless Neovim' })

-- Enable treesitter highlighting and indentation for all filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('ts-highlight', { clear = true }),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

-- nvim-ts-autotag
-- setup('nvim-ts-autotag', {
--   opts = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
-- })

-- treesitter-context
setup('treesitter-context', { enable = true })

-- blink.cmp
local blink_ok = setup('blink.cmp', {
  appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = 'mono' },
  fuzzy = {
    implementation = 'rust',
    prebuilt_binaries = { download = true, force_version = 'v1.8.0' },
  },
  completion = {
    menu = { draw = { columns = { { 'kind_icon', 'label', 'label_description', 'source_name', gap = 1 } }, treesitter = { 'lsp' } } },
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
  },
  cmdline = { enabled = true, completion = { menu = { auto_show = true } } },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
})

vim.g.fff = { lazy_sync = true }
vim.keymap.set('n', 'ff', function()
  require('fff').find_files()
end, { desc = 'Find files' })
vim.keymap.set('n', 'fg', function()
  require('fff').live_grep()
end, { desc = 'Live grep' })

--------------------------------------------------------------------------------
-- NATIVE LSP
--------------------------------------------------------------------------------

local capabilities = {}
if blink_ok then
  capabilities = require('blink.cmp').get_lsp_capabilities({
    workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
  })
end

vim.lsp.config('*', { capabilities = capabilities })

local ok_lsp, lsp_err = pcall(vim.lsp.enable, {
  'gopls',
  'ty',
  'astro',
  'ruff',
  'lua_ls',
  'eslint',
  'oxlint',
  'tsgo',
  'clangd',
  'rust_analyzer',
  'html',
  'emmet_language_server',
  'graphql',
  'cssls',
  'tailwindcss',
  'svelte',
  'wgsl_analyzer',
})
if not ok_lsp then
  vim.notify_once(('LSP enable failed: %s'):format(tostring(lsp_err)), vim.log.levels.WARN)
end

--------------------------------------------------------------------------------
-- CUSTOM MODULES
--------------------------------------------------------------------------------

pcall(function()
  require('dashboard').setup()
end)
