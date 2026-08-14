return {
	src = "sindrets/diffview.nvim",
	config = function()
		require("diffview").setup({})
		-- stylua: ignore start
		vim.keymap.set("n", "<leader>mo", "<cmd>DiffviewOpen<cr>", { desc = "Open diff view" })
		vim.keymap.set("n", "<leader>mc", "<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>", { desc = "Close diff view" })
		vim.keymap.set("n", "<leader>mf", "<cmd>DiffviewFileHistory<cr>", { desc = "View file history" })
		vim.keymap.set("n", "<leader>mF", "<cmd>DiffviewFileHistory %<cr>", { desc = "View current file history" })
		-- stylua: ignore end
	end,
}
