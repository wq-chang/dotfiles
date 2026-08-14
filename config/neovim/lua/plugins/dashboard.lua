return {
	src = "nvimdev/dashboard-nvim",
	after = { "nvim-web-devicons" },
	opts = {
		config = {
			project = {
				action = "FzfLua files cwd=",
			},
		},
	},
}
