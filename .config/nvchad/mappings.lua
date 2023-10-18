---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up" },

    ["<leader>tx"] = { "<cmd>TroubleToggle<cr>" },
    ["<leader>tw"] = { "<cmd>TroubleToggle workspace_diagnostics<cr>" },
    ["<leader>td"] = { "<cmd>TroubleToggle document_diagnostics<cr>" },
    ["<leader>tq"] = { "<cmd>TroubleToggle quickfix<cr>" },
    ["<leader>tl"] = { "<cmd>TroubleToggle loclist<cr>" },
    ["gR"] = { "<cmd>TroubleToggle lsp_references<cr>" },
  },
  v = {
    [">"] = { ">gv", "indent" },
  },
}

-- more keybinds!
M.disabled = {
  n = {
    -- ["<A-h>"] = "",
    -- ["<A-l>"] = "",
  },
}

return M
