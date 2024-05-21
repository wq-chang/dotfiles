return {
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
		opts = {
			config = {
				project = {
					action = "FzfLua files cwd=",
				},
			},
		},
	},
}
