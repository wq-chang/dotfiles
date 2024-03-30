local map = require("utils").map

return {
	{
		"gbprod/yanky.nvim",
		opts = {
			highlight = {
				on_yank = false,
				on_put = false,
			},
		},
		config = function(_, opts)
			require("yanky").setup(opts)
			map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
			map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
			map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
			map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
			map("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
			map("n", "<c-n>", "<Plug>(YankyNextEntry)")
		end,
	},
}
