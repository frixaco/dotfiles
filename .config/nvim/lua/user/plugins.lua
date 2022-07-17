require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Packer can manage itself
  use {
    "williamboman/nvim-lsp-installer",
    "neovim/nvim-lspconfig", -- LSP support
  }
  use { 'ms-jpq/coq_nvim', branch = 'coq' } -- Autocompletion plugin

  -- use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  -- use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  -- use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  -- use 'L3MON4D3/LuaSnip' -- Snippets plugin

  use {
      'nvim-telescope/telescope.nvim',
      requires = { {'nvim-lua/plenary.nvim'} }
    }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' } -- Post-install/update hook with neovim command
  use {'luisiacc/gruvbox-baby', branch = 'main'} -- Colorscheme
  use 'windwp/nvim-autopairs' -- Autopair
  use {
    'kyazdani42/nvim-tree.lua', -- File explorer
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    }
  }
  use 'lewis6991/gitsigns.nvim' -- Git integration for buffers
  use {
    'nvim-lualine/lualine.nvim', -- Statusline
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use 'unblevable/quick-scope' -- Left-Right movement
end)

require('gitsigns').setup()