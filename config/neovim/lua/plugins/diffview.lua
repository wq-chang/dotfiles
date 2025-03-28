return {
	"sindrets/diffview.nvim",
	keys = {
		{
			"<leader>mo",
			"<cmd>DiffviewOpen<cr>",
			desc = "Open diff view",
		},
		{
			"<leader>mc",
			"<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>",
			desc = "Close diff view",
		},
		{
			"<leader>mf",
			"<cmd>DiffviewFileHistory<cr>",
			mode = "n",
			desc = "View file history",
		},
		{
			"<leader>mF",
			"<cmd>DiffviewFileHistory %<cr>",
			desc = "View current file history",
		},
	},
	opts = {},
}
