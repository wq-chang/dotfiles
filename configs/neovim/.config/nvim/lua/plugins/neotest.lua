return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"rcasia/neotest-java",
			"nvim-neotest/neotest-python",
		},
		-- stylua: ignore
		keys = {
			{ "<leader>ns", "<cmd>Neotest summary<cr>", desc = "Neotest summary" },
			{ "<leader>nS", "<cmd>Neotest stop<cr>", desc = "Stop" },
			{ "<leader>nd", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Dubeg test" },
			{ "<leader>nm", "<cmd>Neotest run<cr>", desc = "Run test" },
			{ "<leader>na", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run all tests" },
			{ "<leader>no", "<cmd>Neotest output<cr>", desc = "Output" },
			{ "<leader>np", "<cmd>Neotest output-panel<cr>", desc = "Output panel" },
		},
		opts = function()
			return {
				adapters = {
					require("neotest-java")({}),
					require("neotest-python")({}),
				},
			}
		end,
	},
}
