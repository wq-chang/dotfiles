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
	config = function(opts)
		require("dashboard").setup(opts)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dashboard",
			callback = function()
				vim.schedule(function()
					pcall(require("mini.clue").enable_buf_triggers)
				end)
			end,
		})
	end,
}
