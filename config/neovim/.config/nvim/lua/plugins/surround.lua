return {
	{
		"kylechui/nvim-surround",
		opts = { keymaps = { visual = "yS" } },
		config = function(_, opts)
			require("nvim-surround").setup(opts)
		end,
	},
}
