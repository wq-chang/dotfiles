return {
	{ src = "antoinemadec/FixCursorHold.nvim" },
	{ src = "nvim-neotest/neotest-python" },
	{ src = "marilari88/neotest-vitest" },
	{ src = "fredrikaverpil/neotest-golang" },
	{
		src = "rcasia/neotest-java",
		config = function()
			-- Ensure the junit console jar exists before java tests run; defer
			-- the (network) `NeotestJava setup` download to first java open
			-- instead of running it at every startup.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "java",
				callback = function()
					local neotest_java_path =
						vim.fn.stdpath("data") .. "/neotest-java"
					local jar_path = vim.fn.glob(
						neotest_java_path
							.. "/junit-platform-console-standalone-*.jar"
					)
					if jar_path == "" then
						vim.cmd("NeotestJava setup")
					end
				end,
			})
		end,
	},
	{
		src = "nvim-neotest/neotest",
		after = {
			"nvim-nio",
			"plenary.nvim",
			"FixCursorHold.nvim",
			"nvim-treesitter",
			"neotest-java",
			"neotest-python",
			"neotest-vitest",
			"neotest-golang",
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
		config = function(opts)
			require("neotest").setup(opts)

			-- stylua: ignore start
			vim.keymap.set("n", "<leader>ns", "<cmd>Neotest summary<cr>", { desc = "Neotest summary" })
			vim.keymap.set("n", "<leader>nS", "<cmd>Neotest stop<cr>", { desc = "Stop" })
			vim.keymap.set("n", "<leader>nd", function() require("neotest").run.run({ strategy = "dap" }) end, { desc = "Debug test" })
			vim.keymap.set("n", "<leader>nm", "<cmd>Neotest run<cr>", { desc = "Run test" })
			vim.keymap.set("n", "<leader>na", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run all tests" })
			vim.keymap.set("n", "<leader>no", "<cmd>Neotest output<cr>", { desc = "Output" })
			vim.keymap.set("n", "<leader>np", "<cmd>Neotest output-panel<cr>", { desc = "Output panel" })
			-- stylua: ignore end
		end,
	},
}
