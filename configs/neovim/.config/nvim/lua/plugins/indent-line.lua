return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
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
	},
}
