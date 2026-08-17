return {
	src = "nvim-mini/mini.clue",
	opts = function()
		local miniclue = require("mini.clue")
		return {
			triggers = {
				-- leader triggers
				{ mode = { "n", "x" }, keys = "<leader>" },

				-- `g` and `z` keys
				{ mode = { "n", "x" }, keys = "g" },
				{ mode = { "n", "x" }, keys = "z" },

				-- `[` and `]` keys
				{ mode = "n", keys = "[" },
				{ mode = "n", keys = "]" },
			},
			clues = {
				-- leader mapping groups
				{ mode = { "n", "x" }, keys = "<leader>a", desc = "+ai" },
				{ mode = { "n", "x" }, keys = "<leader>c", desc = "+code" },
				{ mode = { "n", "x" }, keys = "<leader>d", desc = "+debug" },
				{
					mode = { "n", "x" },
					keys = "<leader>f",
					desc = "+file/find",
				},
				{ mode = { "n", "x" }, keys = "<leader>g", desc = "+git" },
				{ mode = { "n", "x" }, keys = "<leader>l", desc = "+lsp" },
				{
					mode = { "n", "x" },
					keys = "<leader>m",
					desc = "+mergetools",
				},
				{ mode = { "n", "x" }, keys = "<leader>n", desc = "+neotest" },
				{ mode = { "n", "x" }, keys = "<leader>w", desc = "+windows" },

				-- Window resize submode: `<leader>w` + j/k/l/h repeats
				{
					mode = "n",
					keys = "<leader>wj",
					postkeys = "<leader>w",
					desc = "Increase height",
				},
				{
					mode = "n",
					keys = "<leader>wk",
					postkeys = "<leader>w",
					desc = "Decrease height",
				},
				{
					mode = "n",
					keys = "<leader>wh",
					postkeys = "<leader>w",
					desc = "Decrease width",
				},
				{
					mode = "n",
					keys = "<leader>wl",
					postkeys = "<leader>w",
					desc = "Increase width",
				},

				-- Window swap submode: `<leader>wx` + h/j/k/l repeats
				{ mode = { "n", "x" }, keys = "<leader>wx", desc = "+swap" },
				{
					mode = "n",
					keys = "<leader>wxh",
					postkeys = "<leader>wx",
					desc = "Swap with left window",
				},
				{
					mode = "n",
					keys = "<leader>wxj",
					postkeys = "<leader>wx",
					desc = "Swap with below window",
				},
				{
					mode = "n",
					keys = "<leader>wxk",
					postkeys = "<leader>wx",
					desc = "Swap with above window",
				},
				{
					mode = "n",
					keys = "<leader>wxl",
					postkeys = "<leader>wx",
					desc = "Swap with right window",
				},

				-- Built-in key combinations
				miniclue.gen_clues.g(),
				miniclue.gen_clues.z(),
				miniclue.gen_clues.square_brackets(),
			},
			window = {
				delay = 300,
				config = {
					width = "auto",
				},
			},
		}
	end,
}
