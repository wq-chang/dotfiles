return {
	{
		src = "nvim-treesitter/nvim-treesitter",
		version = "main",
		priority = 100,
		build = ":TSUpdate",
		opts = {
			languages = {
				"bash",
				"css",
				"diff",
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
				"kotlin",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"mermaid",
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
		},
		config = function(opts)
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
		src = "nvim-treesitter/nvim-treesitter-textobjects",
		version = "main",
		after = { "nvim-treesitter" },
		config = function()
			local move = require("nvim-treesitter-textobjects.move")
			local select = require("nvim-treesitter-textobjects.select")

			local text_objects = {
				a = "parameter",
				c = "conditional",
				f = "function",
				l = "loop",
			}

			local mappings = {}

			for key, obj in pairs(text_objects) do
				local upper = string.upper(key)
				local inner = "@" .. obj .. ".inner"
				local outer = "@" .. obj .. ".outer"

				mappings["]" .. key] = {
					outer,
					{ "n", "x", "o" },
					move.goto_next_start,
					"Next " .. obj,
				}
				mappings["]" .. upper] = {
					outer,
					{ "n", "x", "o" },
					move.goto_next_end,
					"Next " .. obj .. " end",
				}
				mappings["[" .. key] = {
					outer,
					{ "n", "x", "o" },
					move.goto_previous_start,
					"Previous " .. obj,
				}
				mappings["[" .. upper] = {
					outer,
					{ "n", "x", "o" },
					move.goto_previous_end,
					"Previous " .. obj .. " end",
				}
				mappings["i" .. key] = {
					inner,
					{ "x", "o" },
					select.select_textobject,
					"Inner " .. obj,
				}
				mappings["a" .. key] = {
					outer,
					{ "x", "o" },
					select.select_textobject,
					"Outer " .. obj,
				}
			end

			for key, def in pairs(mappings) do
				local textobj, modes, func, desc =
					def[1], def[2], def[3], def[4]
				vim.keymap.set(modes, key, function()
					func(textobj, "textobjects")
				end, { desc = desc })
			end
		end,
	},
	{
		src = "nvim-treesitter/nvim-treesitter-context",
		after = { "nvim-treesitter" },
	},
}
