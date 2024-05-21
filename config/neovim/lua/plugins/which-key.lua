return {
	{
		"folke/which-key.nvim",
		opts = {
			plugins = { spelling = true },
			window = {
				border = "single",
			},
			defaults = {
				mode = { "n", "v" },
				["g"] = { name = "+goto" },
				["z"] = { name = "+fold" },
				["]"] = { name = "+next" },
				["["] = { name = "+prev" },
				["<leader>d"] = { name = "+debug" },
				["<leader>f"] = { name = "+file/find" },
				["<leader>g"] = { name = "+git" },
				["<leader>gh"] = { name = "+hunks" },
				["<leader>l"] = { name = "+lsp" },
				["<leader>m"] = { name = "+mergetools" },
				["<leader>n"] = { name = "+neotest" },
				["<leader>w"] = { name = "+windows" },
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.register(opts.defaults)
		end,
	},
}
