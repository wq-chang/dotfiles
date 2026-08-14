return {
	src = "lukas-reineke/indent-blankline.nvim",
	config = function(opts)
		require("ibl").setup(opts)
	end,
	opts = {
		indent = {
			char = "│",
			tab_char = "│",
		},
		exclude = {
			filetypes = {
				"help",
				"alpha",
				"dashboard",
				"Trouble",
				"trouble",
				"lazy",
				"mason",
				"toggleterm",
			},
		},
	},
}
