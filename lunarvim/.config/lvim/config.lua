--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "tokyonight"

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = false
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"
local set = vim.opt -- set options
set.fillchars = set.fillchars + "diff:╱"
-- vim.opt.laststatus = 3
-- vim.api.nvim_set_hl("tokyonight", "DiffDelete", "guifg=#4D384D guibg=#312A3C")
vim.cmd("highlight DiffDelete guifg=#4D384D guibg=#312A3C")

vim.cmd('imap <silent><script><expr> <C-j> copilot#Accept("")')
vim.cmd("let g:copilot_no_tab_map = v:true")
vim.cmd("let g:copilot_assume_mapped = v:true")

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- local ft_to_parser = require("nvim-treesitter.parsers").filetype_to_parsername
-- ft_to_parser.mdx = "markdown" -- the someft filetype will use the python parser and queries.

-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope session-lens search_session<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Wordspace Diagnostics" },
-- - }
lvim.builtin.which_key.mappings["t"] = {
	name = "+Terminal",
	t = { "<cmd>ToggleTerm<cr>", "ToggleTerm" },
}

lvim.builtin.which_key.mappings["gd"] = {
	"<cmd>DiffviewOpen<cr>",
	"Diffview Open",
}
lvim.builtin.which_key.mappings["gD"] = {
	"<cmd>DiffviewClose<cr>",
	"Diffview Close",
}
lvim.builtin.which_key.mappings["gg"] = {
	"<cmd>LazyGit<cr>",
	"LazyGit",
}

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0
lvim.builtin.nvimtree.setup.actions.open_file.quit_on_open = true

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
	"bash",
	"c",
	"javascript",
	"json",
	"lua",
	"python",
	"typescript",
	"tsx",
	"css",
	"rust",
	"java",
	"yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skiipped for the current filetype
-- vim.tbl_map(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	--   { command = "black", filetypes = { "python" } },
	--   { command = "isort", filetypes = { "python" } },
	-- { command = "stylua", filetypes = { "lua" } },
	{
		-- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
		command = "prettier",
		---@usage arguments to pass to the formatter
		-- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
		-- extra_args = { "--print-with", "100" },
		---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
		filetypes = {
			"typescript",
			"typescriptreact",
			"javascript",
			"javascriptreact",
			"vue",
			"css",
			"scss",
			"html",
			"json",
			"jsonc",
			"yaml",
			"markdown",
			"less",
			"graphql",
		},
	},
})

-- -- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "shellcheck",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--severity", "warning" },
--   },
--   {
--     command = "codespell",
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "python" },
--   },
-- }

-- Additional Plugins
lvim.plugins = {
	{ "folke/tokyonight.nvim" },
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
	},
	{ "rmagatti/auto-session" },
	{ "rmagatti/session-lens" },
	{
		"sindrets/diffview.nvim",
		event = "BufRead",
	},
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	-- {
	-- 	"aca/emmet-ls",
	-- 	config = function()
	-- 		local lspconfig = require("lspconfig")
	-- 		local configs = require("lspconfig/configs")

	-- 		local capabilities = vim.lsp.protocol.make_client_capabilities()
	-- 		capabilities.textDocument.completion.completionItem.snippetSupport = true
	-- 		capabilities.textDocument.completion.completionItem.resolveSupport = {
	-- 			properties = {
	-- 				"documentation",
	-- 				"detail",
	-- 				"additionalTextEdits",
	-- 			},
	-- 		}

	-- 		if not lspconfig.emmet_ls then
	-- 			configs.emmet_ls = {
	-- 				default_config = {
	-- 					cmd = { "emmet-ls", "--stdio" },
	-- 					filetypes = {
	-- 						"html",
	-- 						"css",
	-- 						"javascript",
	-- 						"typescript",
	-- 						"eruby",
	-- 						"typescriptreact",
	-- 						"javascriptreact",
	-- 						"svelte",
	-- 						"vue",
	-- 					},
	-- 					root_dir = function(fname)
	-- 						return vim.loop.cwd()
	-- 					end,
	-- 					settings = {},
	-- 				},
	-- 			}
	-- 		end
	-- 		lspconfig.emmet_ls.setup({
	-- 			capabilities = capabilities,
	-- 			filetypes = {
	-- 				"html",
	-- 				"css",
	-- 			},
	-- 		})
	-- 	end,
	-- },
	{ "kdheepak/lazygit.nvim" },
	{ "ggandor/lightspeed.nvim" },
	{ "knubie/vim-kitty-navigator" },
	{ "mg979/vim-visual-multi" },
	-- { "github/copilot.vim" },
}

-- autocmd BufNewFile,BufRead *.mdx set filetype=markdown.mdx
-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--   -- { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
--   { "BufNewFile,BufRead", "*.mdx", "set filetype=markdown.mdx" },
-- }
