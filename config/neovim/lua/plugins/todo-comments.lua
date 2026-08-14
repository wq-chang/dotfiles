return {
	src = "folke/todo-comments.nvim",
	after = { "plenary.nvim" },
	opts = {
		signs = false,
		search = {
			command = "rg",
			args = {
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--hidden",
			},
		},
	},
	config = function(opts)
		local tc = require("todo-comments")
		tc.setup(opts)
		local function map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { desc = desc })
		end

		-- stylua: ignore start
		map("<leader>ft", "<cmd>TodoQuickFix<cr>", "Find todo comments")
		map("]t", function() tc.jump_next() end, "Next todo comment")
		map("[t", function() tc.jump_prev() end, "Previous todo comment")
		-- stylua: ignore end
	end,
}
