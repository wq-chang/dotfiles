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
			"marilari88/neotest-vitest",
			"fredrikaverpil/neotest-golang",
		},
		-- stylua: ignore
		keys = {
			{ "<leader>ns", "<cmd>Neotest summary<cr>", desc = "Neotest summary" },
			{ "<leader>nS", "<cmd>Neotest stop<cr>", desc = "Stop" },
			---@diagnostic disable-next-line: missing-fields
			{ "<leader>nd", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Dubeg test" },
			{ "<leader>nm", "<cmd>Neotest run<cr>", desc = "Run test" },
			{ "<leader>na", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run all tests" },
			{ "<leader>no", "<cmd>Neotest output<cr>", desc = "Output" },
			{ "<leader>np", "<cmd>Neotest output-panel<cr>", desc = "Output panel" },
		},
		opts = function()
			return {
				adapters = {
					require("neotest-java"),
					require("neotest-python"),
					require("neotest-vitest"),
					require("neotest-golang")({
						runner = "gotestsum",
					}),
				},
			}
		end,
	},
	{
		"rcasia/neotest-java",
		-- TODO: The latest version is broken (2026-01-17), check again later.
		commit = "65b4ee5ebb2884bb752e451c15cb334e3f477ca6",
		config = function()
			local neotest_java_path = vim.fn.stdpath("data") .. "/neotest-java"
			local jar_path = vim.fn.glob(
				neotest_java_path .. "/junit-platform-console-standalone-*.jar"
			)
			if jar_path == "" then
				vim.cmd("NeotestJava setup")
			end
		end,
	},
	{
		"fredrikaverpil/neotest-golang",
		version = "*",
	},
}
