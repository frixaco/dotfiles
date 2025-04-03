local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.scrolloff = 3
vim.g.have_nerd_font = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.confirm = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- SIMPLE LspProgress notification
-- vim.api.nvim_create_autocmd("LspProgress", {
-- 	---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
-- 	callback = function(ev)
-- 		local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
-- 		vim.notify(vim.lsp.status(), "info", {
-- 			id = "lsp_progress",
-- 			title = "LSP Progress",
-- 			opts = function(notif)
-- 				notif.icon = ev.data.params.value.kind == "end" and " "
-- 					or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
-- 			end,
-- 		})
-- 	end,
-- })

-- ADVANCED LspProgress notification
---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
	---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
		if not client or type(value) ~= "table" then
			return
		end
		local p = progress[client.id]
		for i = 1, #p + 1 do
			if i == #p + 1 or p[i].token == ev.data.params.token then
				p[i] = {
					token = ev.data.params.token,
					msg = ("[%3d%%] %s%s"):format(
						value.kind == "end" and 100 or value.percentage or 100,
						value.title or "",
						value.message and (" **%s**"):format(value.message) or ""
					),
					done = value.kind == "end",
				}
				break
			end
		end
		local msg = {} ---@type string[]
		progress[client.id] = vim.tbl_filter(function(v)
			return table.insert(msg, v.msg) or not v.done
		end, p)

		local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		vim.notify(table.concat(msg, "\n"), "info", {
			id = "lsp_progress",
			title = client.name,
			opts = function(notif)
				notif.icon = #progress[client.id] == 0 and " "
					or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
			end,
		})
	end,
})

require("lazy").setup({
	spec = {
		{
			"catppuccin/nvim",
			name = "catppuccin",
			lazy = false,
			priority = 1000,
			config = function()
				vim.cmd.colorscheme("catppuccin")
			end,
		},

		{
			"folke/lazydev.nvim",
			event = "VeryLazy",
			config = function()
				require("lazydev").setup({
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
						{ path = "wezterm-types", mods = { "wezterm" } },
					},
				})
			end,
		},

		{
			"saghen/blink.cmp",
			event = "VeryLazy",
			-- optional: provides snippets for the snippet source
			dependencies = {},
			-- use a release tag to download pre-built binaries
			version = "*",
			opts = {
				keymap = {
					preset = "none",

					["<Tab>"] = { "select_next", "fallback" },
					["<S-Tab>"] = { "select_prev", "fallback" },

					["<cr>"] = { "select_and_accept", "fallback" },

					["<C-n>"] = { "snippet_forward", "fallback" },
					["<C-p>"] = { "snippet_backward", "fallback" },

					["<C-y>"] = { "select_and_accept" },
					["<C-e>"] = { "cancel" },

					["<C-Space>"] = { "show" },
				},
				fuzzy = {
					implementation = "rust",
				},
				completion = { list = { selection = { preselect = true, auto_insert = true } } },
				cmdline = {
					enabled = true,
					completion = { menu = { auto_show = true } },
				},
				sources = {
					default = { "lazydev", "lsp", "path", "snippets", "buffer" },
					providers = {
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							-- make lazydev completions top priority (see `:h blink.cmp`)
							score_offset = 100,
						},
					},
				},
			},
		},

		{
			"neovim/nvim-lspconfig",
			event = "VeryLazy",
			dependencies = {
				{
					"williamboman/mason.nvim",
					opts = {
						ui = {
							border = "rounded", -- Optional: for a nicer UI
						},
					},
				},
				"williamboman/mason-lspconfig.nvim",
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				"saghen/blink.cmp",
			},
			opts = {
				servers = {
					lua_ls = {},
				},
			},
			config = function(_, opts)
				require("mason").setup()
				require("mason-lspconfig").setup({
					ensure_installed = {
						"lua_ls",
						"ts_ls",
					},
					automatic_installation = true,
				})
				require("mason-tool-installer").setup({
					ensure_installed = {
						"stylua",
						"prettier",
						"eslint_d",
					},
					auto_update = true,
					run_on_start = true,
				})

				local lspconfig = require("lspconfig")
				for server, config in pairs(opts.servers) do
					-- passing config.capabilities to blink.cmp merges with the capabilities in your
					-- `opts[server].capabilities, if you've defined it
					config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
					lspconfig[server].setup(config)
				end
			end,
		},

		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			opts = {
				format_on_save = function(bufnr)
					-- Disable "format_on_save lsp_fallback" for languages that don't
					-- have a well standardized coding style. You can add additional
					-- languages here or re-enable it for the disabled ones.
					local disable_filetypes = { c = true, cpp = true }
					if disable_filetypes[vim.bo[bufnr].filetype] then
						return nil
					else
						return {
							timeout_ms = 500,
							lsp_format = "fallback",
						}
					end
				end,
				formatters_by_ft = {
					lua = { "stylua" },
				},
			},
		},

		{
			"nvim-treesitter/nvim-treesitter",
			event = "VeryLazy",
			build = ":TSUpdate",
			main = "nvim-treesitter.configs", -- Sets main module to use for opts
			-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
			opts = {
				ensure_installed = {
					"c",
					"cpp",
					"html",
					"css",
					"xml",
					"go",
					"lua",
					"python",
					"astro",
					"svelte",
					"rust",
					"hcl",
					"tsx",
					"javascript",
					"typescript",
					"vimdoc",
					"vim",
					"bash",
					"yaml",
					"graphql",
					"toml",
					"regex",
					"json",
					"jsonc",
					"markdown",
					"markdown_inline",
					"sql",
					"git_config",
					"gitignore",
				},
				-- Autoinstall languages that are not installed
				auto_install = true,
				highlight = {
					enable = true,
					-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
					--  If you are experiencing weird indenting issues, add the language to
					--  the list of additional_vim_regex_highlighting and disabled languages for indent.
					additional_vim_regex_highlighting = { "ruby" },
				},
				indent = { enable = true, disable = { "ruby" } },
			},
		},

		{
			"windwp/nvim-ts-autotag",
			config = function()
				require("nvim-ts-autotag").setup({
					opts = {
						-- Defaults
						enable_close = true, -- Auto close tags
						enable_rename = true, -- Auto rename pairs of tags
						enable_close_on_slash = false, -- Auto close on trailing </
					},
					-- Also override individual filetype configs, these take priority.
					-- Empty by default, useful if one of the "opts" global settings
					-- doesn't work well in a specific filetype
					per_filetype = {
						["html"] = {
							enable_close = false,
						},
					},
				})
			end,
		},

		{
			"nvim-treesitter/nvim-treesitter-context",
			event = "VeryLazy",
			config = function()
				require("treesitter-context").setup({
					enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
					multiwindow = false, -- Enable multiwindow support.
					max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
					min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
					line_numbers = true,
					multiline_threshold = 20, -- Maximum number of lines to show for a single context
					trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
					mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
					-- Separator between context and content. Should be a single character string, like '-'.
					-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
					separator = nil,
					zindex = 20, -- The Z-index of the context window
					on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
				})
			end,
		},

		{
			"folke/snacks.nvim",
			priority = 1000,
			lazy = false,
			---@type snacks.Config
			opts = {
				bigfile = { enabled = true },
				dashboard = { enabled = true },
				notifier = { enabled = true },
				lazygit = { enabled = true },
				scroll = { enabled = true },
				statuscolumn = { enabled = true },
				indent = {
					priority = 1,
					enabled = true,
					animate = {
						enabled = false,
					},
					scope = {
						enabled = true,
						underline = true,
					},
				},
				explorer = { enabled = true },
				picker = {
					enabled = true,
					sources = {
						explorer = {
							ignored = true,
							hidden = true,
						},
						files = {
							ignored = false,
							show_empty = true,
							hidden = true,
							follow = true,
						},
					},
					exclude = {
						"node_modules",
						".git",
						".venv",
						".next",
					},
				},
				styles = {},
			},
			keys = {
				{
					"<leader>b",
					function()
						Snacks.explorer()
					end,
					desc = "File Explorer",
				},
				{
					"<leader>gg",
					function()
						Snacks.lazygit()
					end,
					desc = "Lazygit",
				},
				{
					"<leader><space>",
					function()
						Snacks.picker.smart()
					end,
					desc = "Smart Find Files",
				},

				{
					"<leader>p",
					function()
						Snacks.picker.files()
					end,
					desc = "Find Files",
				},
				{
					"<leader>l",
					function()
						Snacks.picker.lines()
					end,
					desc = "Grep Buffer",
				},
				{
					"<leader>fg",
					function()
						Snacks.picker.grep()
					end,
					desc = "Grep Files",
				},
				{
					"<leader>fh",
					function()
						Snacks.picker.help()
					end,
					desc = "Help Pages",
				},
			},
		},

		{
			"lewis6991/gitsigns.nvim",
			event = "VeryLazy",
			opts = {
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end)

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end)

					-- Actions
					map("n", "<leader>hs", gitsigns.stage_hunk)
					map("n", "<leader>hr", gitsigns.reset_hunk)

					map("v", "<leader>hs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)

					map("v", "<leader>hr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)

					map("n", "<leader>hS", gitsigns.stage_buffer)
					map("n", "<leader>hR", gitsigns.reset_buffer)
					map("n", "<leader>hp", gitsigns.preview_hunk)
					map("n", "<leader>hi", gitsigns.preview_hunk_inline)

					map("n", "<leader>hb", function()
						gitsigns.blame_line({ full = true })
					end)

					map("n", "<leader>hd", gitsigns.diffthis)

					map("n", "<leader>hD", function()
						gitsigns.diffthis("~")
					end)

					map("n", "<leader>hQ", function()
						gitsigns.setqflist("all")
					end)
					map("n", "<leader>hq", gitsigns.setqflist)

					-- Toggles
					map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
					map("n", "<leader>td", gitsigns.toggle_deleted)
					map("n", "<leader>tw", gitsigns.toggle_word_diff)

					-- Text object
					map({ "o", "x" }, "ih", gitsigns.select_hunk)
				end,
			},
		},

		{
			"otavioschwanck/arrow.nvim",
			event = "VeryLazy",
			dependencies = {},
			opts = {
				show_icons = true,
				leader_key = ";",
				buffer_leader_key = "m",
			},
		},

		{
			"folke/todo-comments.nvim",
			event = "VeryLazy",
			opts = {},
			keys = {
				{
					"<leader>st",
					function()
						Snacks.picker.todo_comments()
					end,
					desc = "Todo",
				},
			},
		},

		-- {
		-- 	"echasnovski/mini.indentscope",
		-- 	event = "VeryLazy",
		-- 	version = false,
		-- 	config = function()
		-- 		local no_indent_animation = require("mini.indentscope").gen_animation.none()
		-- 		require("mini.indentscope").setup({
		-- 			draw = {
		-- 				animation = no_indent_animation,
		-- 			},
		-- 			symbol = "│",
		-- 		})
		-- 	end,
		-- },

		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
			-- use opts = {} for passing setup options
			-- this is equivalent to setup({}) function
		},

		{
			"yetone/avante.nvim",
			event = "VeryLazy",
			version = false, -- Never set this value to "*"! Never!
			opts = {
				provider = "openrouter",
				vendors = {
					openrouter = {
						__inherited_from = "openai",
						endpoint = "https://openrouter.ai/api/v1",
						api_key_name = "OPENROUTER_API_KEY",
						-- model = "google/gemini-2.5-pro-exp-03-25",
						-- model = "deepseek/deepseek-chat-v3-0324",
						model = "anthropic/claude-3.5-sonnet",
					},
				},
			},
			-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
			build = "make",
			-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"stevearc/dressing.nvim",
				"nvim-lua/plenary.nvim",
				"MunifTanjim/nui.nvim",
				--- The below dependencies are optional,
				"echasnovski/mini.pick", -- for file_selector provider mini.pick
				"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
				-- 'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
				-- 'ibhagwan/fzf-lua', -- for file_selector provider fzf
				"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
				{
					-- support for image pasting
					"HakonHarnes/img-clip.nvim",
					event = "VeryLazy",
					opts = {
						-- recommended settings
						default = {
							embed_image_as_base64 = false,
							prompt_for_file_name = false,
							drag_and_drop = {
								insert_mode = true,
							},
							-- required for Windows users
							use_absolute_path = true,
						},
					},
				},
				{
					-- Make sure to set this up properly if you have lazy=true
					"MeanderingProgrammer/render-markdown.nvim",
					opts = {
						file_types = { "markdown", "Avante" },
					},
					ft = { "markdown", "Avante" },
				},
			},
		},

		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = {},
		},

		-- { "echasnovski/mini.statusline", version = false, opts = {} },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "catppuccin" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- {
-- 	"nvim-telescope/telescope.nvim",
-- 	tag = "0.1.8",
-- 	dependencies = {
-- 		"nvim-lua/plenary.nvim",
-- 		{
-- 			"nvim-telescope/telescope-fzf-native.nvim",
-- 			-- build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
-- 			build = "make",
-- 		},
-- 	},
-- 	config = function()
-- 		require("telescope").setup({
-- 			-- defaults = {
-- 			-- 	file_ignore_patterns = { ".git/*" },
-- 			-- },
-- 			extensions = {
-- 				fzf = {
-- 					fuzzy = true, -- false will only do exact matching
-- 					override_generic_sorter = true, -- override the generic sorter
-- 					override_file_sorter = true, -- override the file sorter
-- 					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
-- 					-- the default case_mode is "smart_case"
-- 				},
-- 			},
-- 		})
--
-- 		require("telescope").load_extension("fzf")
--
-- 		vim.keymap.set("n", "<leader>p", function()
-- 			require("telescope.builtin").find_files({
-- 				hidden = true,
-- 				follow = true,
-- 			})
-- 		end, {})
--
-- 		vim.keymap.set("n", "<leader>g", function()
-- 			require("telescope.builtin").current_buffer_fuzzy_find()
-- 		end, {})
--
-- 		vim.keymap.set("n", "<leader>fg", function()
-- 			require("telescope.builtin").live_grep({
-- 				additional_args = function()
-- 					return { "--hidden", "--follow" }
-- 				end,
-- 			})
-- 		end, {})
--
-- 		vim.keymap.set("n", "<leader>fh", function()
-- 			require("telescope.builtin").help_tags()
-- 		end, {})
-- 	end,
-- },
