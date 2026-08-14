return {
	src = "danymat/neogen",
	opts = {
		snippet_engine = "luasnip",
	},
	config = function(opts)
		require("neogen").setup(opts)
		vim.keymap.set(
			"n",
			"<leader>cg",
			"<cmd>Neogen<cr>",
			{ desc = "Generate docstring" }
		)
	end,
}
