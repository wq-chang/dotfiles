return {
	{
		"folke/tokyonight.nvim",
		opts = {
			style = "night",
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			local colors = require("tokyonight.colors").setup()
			vim.api.nvim_set_hl(
				0,
				"InactiveText",
				{ fg = colors.dark3, bg = colors.bg_float }
			)
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
}
