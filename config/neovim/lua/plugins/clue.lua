return {
	src = "nvim-mini/mini.clue",
	opts = function()
		local miniclue = require("mini.clue")
		return {
			triggers = {
				-- Leader triggers
				{ mode = { "n", "x" }, keys = "<Leader>" },

				-- `g` and `z` keys
				{ mode = { "n", "x" }, keys = "g" },
				{ mode = { "n", "x" }, keys = "z" },

				-- `[` and `]` keys
				{ mode = "n", keys = "[" },
				{ mode = "n", keys = "]" },
			},
			clues = {
				-- Leader mapping groups
				{ mode = { "n", "x" }, keys = "<Leader>a", desc = "+ai" },
				{ mode = { "n", "x" }, keys = "<Leader>c", desc = "+code" },
				{ mode = { "n", "x" }, keys = "<Leader>d", desc = "+debug" },
				{
					mode = { "n", "x" },
					keys = "<Leader>f",
					desc = "+file/find",
				},
				{ mode = { "n", "x" }, keys = "<Leader>g", desc = "+git" },
				{ mode = { "n", "x" }, keys = "<Leader>l", desc = "+lsp" },
				{
					mode = { "n", "x" },
					keys = "<Leader>m",
					desc = "+mergetools",
				},
				{ mode = { "n", "x" }, keys = "<Leader>n", desc = "+neotest" },
				{ mode = { "n", "x" }, keys = "<Leader>w", desc = "+windows" },

				-- Window resize submode: `<Leader>w` + j/k/l/h repeats
				{
					mode = "n",
					keys = "<Leader>wj",
					postkeys = "<Leader>w",
					desc = "Increase height",
				},
				{
					mode = "n",
					keys = "<Leader>wk",
					postkeys = "<Leader>w",
					desc = "Decrease height",
				},
				{
					mode = "n",
					keys = "<Leader>wh",
					postkeys = "<Leader>w",
					desc = "Decrease width",
				},
				{
					mode = "n",
					keys = "<Leader>wl",
					postkeys = "<Leader>w",
					desc = "Increase width",
				},

				-- Window swap submode: `<Leader>wx` + h/j/k/l repeats
				{ mode = { "n", "x" }, keys = "<Leader>wx", desc = "+swap" },
				{
					mode = "n",
					keys = "<Leader>wxh",
					postkeys = "<Leader>wx",
					desc = "Swap with left window",
				},
				{
					mode = "n",
					keys = "<Leader>wxj",
					postkeys = "<Leader>wx",
					desc = "Swap with below window",
				},
				{
					mode = "n",
					keys = "<Leader>wxk",
					postkeys = "<Leader>wx",
					desc = "Swap with above window",
				},
				{
					mode = "n",
					keys = "<Leader>wxl",
					postkeys = "<Leader>wx",
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
