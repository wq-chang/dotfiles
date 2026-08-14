return {
	{
		src = "JoosepAlviste/nvim-ts-context-commentstring",
		after = { "nvim-treesitter" },
		opts = {
			enable_autocmd = false,
		},
	},
	{
		src = "numToStr/Comment.nvim",
		after = { "nvim-ts-context-commentstring" },
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("Comment").setup({
				pre_hook = require(
					"ts_context_commentstring.integrations.comment_nvim"
				).create_pre_hook(),
			})
		end,
	},
}
