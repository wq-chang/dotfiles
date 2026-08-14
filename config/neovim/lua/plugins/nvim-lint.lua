return {
	src = "mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			go = { "golangcilint" },
			terraform = { "tflint" },
			sql = { "sqlfluff" },
		}
		vim.api.nvim_create_autocmd(
			{ "BufWritePost", "BufReadPost", "InsertLeave" },
			{
				group = vim.api.nvim_create_augroup(
					"nvim-lint",
					{ clear = true }
				),
				callback = function()
					lint.try_lint()
				end,
			}
		)
	end,
}
