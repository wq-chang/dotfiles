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
			{ "<leader>nd", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Dubug test" },
			{ "<leader>nm", "<cmd>Neotest run<cr>", desc = "Run test" },
			{ "<leader>na", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run all tests" },
			{ "<leader>no", "<cmd>Neotest output<cr>", desc = "Output" },
			{ "<leader>np", "<cmd>Neotest output-panel<cr>", desc = "Output panel" },
		},
		opts = function()
			local go_utils = require("utils.go")
			local default_go_test_args = { "-v", "-race", "-count=1" }

			local function integration_build_args()
				return go_utils.current_test_build_flags()
			end

			return {
				adapters = {
					require("neotest-java"),
					require("neotest-python"),
					require("neotest-vitest"),
					require("neotest-golang")({
						runner = "gotestsum",
						go_test_args = function()
							return vim.list_extend(
								vim.deepcopy(default_go_test_args),
								integration_build_args()
							)
						end,
						go_list_args = integration_build_args,
						dap_mode = "manual",
						dap_manual_config = function()
							return vim.tbl_extend(
								"force",
								go_utils.current_debug_test_config(),
								{
									mode = "test",
									name = "Debug go tests",
									outputMode = "remote",
									request = "launch",
									type = "go",
								}
							)
						end,
					}),
				},
			}
		end,
	},
	{
		"rcasia/neotest-java",
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
