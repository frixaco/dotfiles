-- Uses vim.pack.add() for plugin management
-- Uses vim.lsp.config() / vim.lsp.enable() for LSP

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
  { src = 'https://github.com/windwp/nvim-ts-autotag' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },

  -- LSP tooling
  { src = 'https://github.com/williamboman/mason.nvim' },
  { src = 'https://github.com/neovim/nvim-lspconfig' }, -- provides default configs

  -- Completion
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1.8.0' },

  -- Picker & utilities
  { src = 'https://github.com/folke/snacks.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },

  -- File picker
  { src = 'https://github.com/dmtrKovalenko/fff.nvim' },
})
if not ok_pack_add then
  vim.notify(('vim.pack.add failed: %s'):format(tostring(pack_add_err)), vim.log.levels.ERROR)
end

-- Manual sync command (opens confirmation UI; hooks run on PackChanged after confirming with :write)
vim.api.nvim_create_user_command('PackSync', function()
  vim.pack.update()
end, { desc = 'Update plugins (confirm with :write)' })

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
vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Previous error' })

vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Next error' })

--------------------------------------------------------------------------------
-- AUTOCMDS
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
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
  vim.keymap.set('n', '<leader>fr', '<cmd>NvimTreeFindFile<CR>', { desc = 'Reveal file in tree', silent = true })
end

-- gitsigns
local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
if gitsigns_ok then
  gitsigns.setup({
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
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
    format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
    formatters_by_ft = {
      lua = { 'stylua' },
      python = function(bufnr)
        if conform.get_formatter_info('ruff_format', bufnr).available then
          return { 'ruff_format' }
        else
          return { 'isort', 'black' }
        end
      end,
      javascript = { 'prettier', 'biome', stop_after_first = true },
      typescript = { 'prettier', 'biome', stop_after_first = true },
      javascriptreact = { 'prettier', 'biome', stop_after_first = true },
      typescriptreact = { 'prettier', 'biome', stop_after_first = true },
      html = { 'prettier', 'biome', stop_after_first = true },
      graphql = { 'prettier', 'biome', stop_after_first = true },
      yaml = { 'prettier', 'biome', stop_after_first = true },
      toml = { 'taplo' },
      json = { 'prettier', 'biome', stop_after_first = true },
      jsonc = { 'prettier', 'biome', stop_after_first = true },
      go = { 'goimports', 'gofmt' },
      c = { 'clang_format' },
      css = { 'prettier', 'biome', stop_after_first = true },
      shell = { 'shfmt', 'shellcheck' },
      zsh = { 'shfmt', 'shellcheck' },
      markdown = { 'prettier', 'biome', stop_after_first = true },
    },
  })
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
  'jsonc',
  'markdown',
  'markdown_inline',
  'sql',
  'git_config',
  'gitignore',
}

-- Install missing parsers on startup (async, non-blocking)
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('ts-ensure-installed', { clear = true }),
  callback = function()
    local installed = {}
    for _, p in ipairs(require('nvim-treesitter.config').get_installed('parsers')) do
      installed[p] = true
    end
    local missing = vim.tbl_filter(function(p)
      return not installed[p]
    end, ts_parsers)
    if #missing > 0 then
      require('nvim-treesitter.install').install(missing, { summary = true })
    end
  end,
})

-- Enable treesitter highlighting and indentation for all filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('ts-highlight', { clear = true }),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

-- nvim-ts-autotag
setup('nvim-ts-autotag', {
  opts = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
})

-- treesitter-context
setup('treesitter-context', { enable = false })

-- mason
setup('mason', { ui = { backdrop = 100 } })

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

-- snacks
local snacks_ok = setup('snacks', {
  bigfile = { enabled = true },
  notifier = { enabled = true },
  statuscolumn = { enabled = true },
  picker = {
    layout = { layout = { backdrop = false } },
    enabled = true,
    sources = {
      explorer = { ignored = true, hidden = true, follow = true },
      files = { ignored = false, show_empty = true, hidden = true, follow = true },
    },
    exclude = { 'node_modules', '.git', '.venv', '.next' },
  },
})

-- Snacks keymaps (only if loaded)
if snacks_ok then
  vim.keymap.set('n', '<leader>l', function()
    Snacks.picker.lines()
  end, { desc = 'Grep Buffer' })
  vim.keymap.set('n', '<leader>fg', function()
    Snacks.picker.grep()
  end, { desc = 'Grep Files' })
  vim.keymap.set('n', '<leader>fh', function()
    Snacks.picker.help()
  end, { desc = 'Help Pages' })
  vim.keymap.set('n', 'gd', function()
    Snacks.picker.lsp_definitions()
  end, { desc = 'Goto Definition' })
  vim.keymap.set('n', 'gr', function()
    Snacks.picker.lsp_references()
  end, { nowait = true, desc = 'References' })
  vim.keymap.set('n', 'gI', function()
    Snacks.picker.lsp_implementations()
  end, { desc = 'Goto Implementation' })
  vim.keymap.set('n', 'gy', function()
    Snacks.picker.lsp_type_definitions()
  end, { desc = 'Goto T[y]pe Definition' })
  vim.keymap.set('n', '<leader>st', function()
    Snacks.picker.todo_comments()
  end, { desc = 'Todo' })
end

vim.g.fff = { lazy_sync = true }
vim.keymap.set('n', '<leader>p', function()
  require('fff').find_files()
end, { desc = 'Open file picker' })

--------------------------------------------------------------------------------
-- NATIVE LSP (vim.lsp.config / vim.lsp.enable)
--------------------------------------------------------------------------------

-- LSP on_attach
local lsp_on_attach = function(client, bufnr)
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end
  map('<leader>e', vim.diagnostic.open_float, 'Open Floating Diagnostic')
  map('<leader>r', vim.lsp.buf.rename, 'Rename')
  map('K', vim.lsp.buf.hover, 'Hover Documentation')
  vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = 'Code Action' })
end

local progress = vim.defaulttable()
local uv = vim.uv
vim.api.nvim_create_autocmd('LspProgress', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local value = ev.data.params.value
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

    local msg = {}
    progress[client.id] = vim.tbl_filter(function(v)
      return table.insert(msg, v.msg) or not v.done
    end, p)

    local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
    vim.notify(table.concat(msg, '\n'), vim.log.levels.INFO, {
      id = 'lsp_progress',
      title = client.name,
      opts = function(notif)
        notif.icon = #progress[client.id] == 0 and ' ' or spinner[math.floor(uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})

-- Get capabilities from blink.cmp (if available)
local capabilities = {}
if blink_ok then
  local blink = require('blink.cmp')
  capabilities = blink.get_lsp_capabilities({
    workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
  })
end

-- LSP servers to enable
local servers = {
  'gopls',
  'ty',
  'astro',
  'ruff',
  'lua_ls',
  'eslint',
  'tsgo',
  'clangd',
  'rust_analyzer',
  'html',
  'emmet_language_server',
  'graphql',
  'cssls',
  'tailwindcss',
  'svelte',
}

-- Optional fallback config (disabled): ts_ls
--[[
pcall(vim.lsp.config, 'ts_ls', {
  capabilities = capabilities,
  on_attach = lsp_on_attach,
  init_options = {
    plugins = {
      { name = 'typescript-svelte-plugin', location = 'node_modules/svelte-language-server' },
    },
  },
})
pcall(vim.lsp.enable, 'ts_ls')
]]

for _, server in ipairs(servers) do
  local ok = pcall(vim.lsp.config, server, { capabilities = capabilities, on_attach = lsp_on_attach })
  if ok then
    pcall(vim.lsp.enable, server)
  else
    vim.notify_once(('Skipping LSP server without config: %s'):format(server), vim.log.levels.WARN)
  end
end

-- Sourcekit (Swift)
pcall(vim.lsp.config, 'sourcekit', { on_attach = lsp_on_attach, capabilities = capabilities })
pcall(vim.lsp.enable, 'sourcekit')

--------------------------------------------------------------------------------
-- CUSTOM MODULES
--------------------------------------------------------------------------------

pcall(function()
  require('dashboard').setup()
end)
