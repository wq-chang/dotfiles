return {
	{
		src = "junegunn/fzf",
		build = function()
			vim.fn["fzf#install"]()
		end,
	},
	{
		src = "kevinhwang91/nvim-bqf",
		after = { "fzf" },
		opts = {
			preview = {
				winblend = 0,
			},
		},
	},
}
