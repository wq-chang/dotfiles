return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				config = function()
					-- When in diff mode, we want to use the default
					-- vim text objects c & C instead of the treesitter ones.
					local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
					local configs = require("nvim-treesitter.configs")
					for name, fn in pairs(move) do
						if name:find("goto") == 1 then
							move[name] = function(q, ...)
								if vim.wo.diff then
									local config = configs.get_module(
										"textobjects.move"
									)[name] ---@type table<string,string>
									for key, query in pairs(config or {}) do
										if
											q == query
											and key:find("[%]%[][cC]")
										then
											vim.cmd("normal! " .. key)
											return
										end
									end
								end
								return fn(q, ...)
							end
						end
					end
				end,
			},
		},
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			ensure_installed = {
				"bash",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"regex",
				"tsx",
				"typescript",
				"vim",
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
			textobjects = {
				move = {
					enable = true,
					goto_next_start = {
						["]a"] = "@parameter.outer",
						["]c"] = "@class.outer",
						["]f"] = "@function.outer",
					},
					goto_next_end = {
						["]A"] = "@parameter.outer",
						["]C"] = "@class.outer",
						["]F"] = "@function.outer",
					},
					goto_previous_start = {
						["[a"] = "@parameter.outer",
						["[c"] = "@class.outer",
						["[f"] = "@function.outer",
					},
					goto_previous_end = {
						["[A"] = "@parameter.outer",
						["[C"] = "@class.outer",
						["[F"] = "@function.outer",
					},
				},
				select = {
					enable = true,
					keymaps = {
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
					},
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{ "m-demare/hlargs.nvim", config = true },
}
