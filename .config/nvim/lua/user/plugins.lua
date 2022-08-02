require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Packer can manage itself
    use {"williamboman/nvim-lsp-installer", "neovim/nvim-lspconfig" -- LSP support
    }
    -- use {
    --     'ms-jpq/coq_nvim',
    --     branch = 'coq'
    -- } -- Autocompletion plugin

    use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
    use 'L3MON4D3/LuaSnip' -- Snippets plugin

    use {
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/plenary.nvim'}}
    }
    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make'
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    } -- Post-install/update hook with neovim command
    use {
        'luisiacc/gruvbox-baby',
        branch = 'main'
    } -- Colorscheme
    use 'Mofiqul/vscode.nvim' -- VSCode colorscheme
    use 'marko-cerovac/material.nvim' -- Material colorscheme
    use 'windwp/nvim-autopairs' -- Autopair
    use {
        'kyazdani42/nvim-tree.lua', -- File explorer
        requires = {'kyazdani42/nvim-web-devicons' -- optional, for file icon
        }
    }
    use 'lewis6991/gitsigns.nvim' -- Git integration for buffers
    use {
        'nvim-lualine/lualine.nvim', -- Statusline
        requires = {
            'kyazdani42/nvim-web-devicons',
            opt = true
        }
    }
    use 'unblevable/quick-scope' -- Left-Right movement
    use {
        'numToStr/Comment.nvim' -- Comment plugin
    }
    use {
        'github/copilot.vim' -- Github Copilot
    }
end)

require('gitsigns').setup {}
require('lualine').setup {
    options = {
        -- theme = 'gruvbox'
        -- theme = 'vscode'
        theme = 'material'
    }
}

require('telescope').setup {
    pickers = {
        buffers = {
            show_all_buffers = true,
            sort_lastused = true,
            theme = "dropdown",
            previewer = false,
            mappings = {
                i = {
                    ["<c-d>"] = "delete_buffer"
                }
            }
        }
    }
}
require('telescope').load_extension('fzf')
-- Find files using
vim.keymap.set('n', '<Leader>ff', '<Cmd>Telescope find_files<CR>', {
    noremap = true
})
-- Find text in all files
vim.keymap.set('n', '<Leader>fg', '<Cmd>Telescope live_grep<CR>', {
    noremap = true
})
-- Find open buffers
vim.keymap.set('n', '<Leader>fb', '<Cmd>Telescope buffers<CR>', {
    noremap = true
})
vim.keymap.set('n', '<Leader>fh', '<Cmd>Telescope help_tags<CR>', {
    noremap = true
})

require('nvim-tree').setup {
    update_cwd = true,
    update_focused_file = {
        enable = true,
        update_cwd = true
    }
}
-- Toggle file explorer
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', {
    noremap = true
})
-- Reload file explorer
vim.keymap.set('n', '<Leader>r', ':NvimTreeRefresh<CR>', {
    noremap = true
})

require('nvim-autopairs').setup {}
require('nvim-treesitter.configs').setup {
    ensure_installed = {"typescript", "tsx", "javascript", "graphql", "json", "css", "lua", "rust", "go", "ruby",
                        "python"},
    highlight = {
        enable = true
    },
    incremental_selection = {
        enable = true
    },
    textobjects = {
        enable = true
    },
    autopairs = {
        enable = true
    }
}

require('Comment').setup {}

-- Material theme
require('material').setup({
	lualine_style = 'default' -- or 'stealth'
})
vim.g.material_style = "deep ocean"
vim.cmd 'colorscheme material'

-- VSCode theme
-- vim.o.background = 'dark'
-- local c = require('vscode.colors')
-- require('vscode').setup({
--     -- Enable transparent background
--     transparent = true,
-- 
--     -- Enable italic comment
--     italic_comments = true,
-- 
--     -- Disable nvim-tree background color
--     disable_nvimtree_bg = true,
-- 
--     -- Override colors (see ./lua/vscode/colors.lua)
--     color_overrides = {
--         vscLineNumber = '#FFFFFF',
--     },
-- 
--     -- Override highlight groups (see ./lua/vscode/theme.lua)
--     group_overrides = {
--         -- this supports the same val table as vim.api.nvim_set_hl
--         -- use colors from this colorscheme by requiring vscode.colors!
--         Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
--     }
-- })

-- Gruvbox theme
-- vim.cmd [[colorscheme gruvbox-baby]]
