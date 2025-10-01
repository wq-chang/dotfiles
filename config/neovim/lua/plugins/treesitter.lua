return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		opts = function()
			return {
				languages = {
					"bash",
					"css",
					"dockerfile",
					"gitignore",
					"go",
					"gomod",
					"gosum",
					"gowork",
					"html",
					"java",
					"javascript",
					"jsdoc",
					"json",
					"jsonc",
					"kotlin",
					"lua",
					"luadoc",
					"markdown",
					"markdown_inline",
					"nix",
					"python",
					"regex",
					"scss",
					"sql",
					"terraform",
					"toml",
					"tsx",
					"typescript",
					"vim",
					"vimdoc",
					"xml",
					"yaml",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
			}
		end,
		config = function(_, opts)
			require("nvim-treesitter").install(opts.languages)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = opts.languages,
				callback = function()
					vim.treesitter.start()
					vim.wo.foldenable = false
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.bo.indentexpr =
						"v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			text_objects = {
				a = "parameter",
				c = "conditional",
				f = "function",
				l = "loop",
			},
		},
		config = function(_, opts)
			local move = require("nvim-treesitter-textobjects.move")
			local select = require("nvim-treesitter-textobjects.select")

			local mappings = {}

			for key, obj in pairs(opts.text_objects) do
				local upper = string.upper(key)
				local inner = "@" .. obj .. ".inner"
				local outer = "@" .. obj .. ".outer"

				-- stylua: ignore start
				mappings["]" .. key] = { outer, { "n", "x", "o" }, move.goto_next_start }
				mappings["]" .. upper] = { outer, { "n", "x", "o" }, move.goto_next_end }
				mappings["[" .. key] = { outer, { "n", "x", "o" }, move.goto_previous_start }
				mappings["[" .. upper] = { outer, { "n", "x", "o" }, move.goto_previous_end }
				mappings["i" .. key] = { inner, { "x", "o" }, select.select_textobject }
				mappings["a" .. key] = { outer, { "x", "o" }, select.select_textobject }
				-- stylua: ignore end
			end

			-- apply all keymaps
			for key, def in pairs(mappings) do
				local textobj, modes, func = def[1], def[2], def[3]
				vim.keymap.set(modes, key, function()
					func(textobj, "textobjects")
				end)
			end
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
}
