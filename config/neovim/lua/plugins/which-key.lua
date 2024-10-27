return {
	{
		"folke/which-key.nvim",
		opts = {
			plugins = { spelling = true },
			win = {
				border = "rounded",
			},
			spec = {
				mode = { "n", "v" },
				{ "g", group = "+goto" },
				{ "z", group = "+fold" },
				{ "]", group = "+next" },
				{ "[", group = "+prev" },
				{ "<leader>c", group = "+code" },
				{ "<leader>d", group = "+debug" },
				{ "<leader>f", group = "+file/find" },
				{ "<leader>g", group = "+git" },
				{ "<leader>gh", group = "+hunks" },
				{ "<leader>l", group = "+lsp" },
				{ "<leader>m", group = "+mergetools" },
				{ "<leader>n", group = "+neotest" },
				{ "<leader>w", group = "+windows" },
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
		end,
	},
}
