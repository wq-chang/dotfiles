return {
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "nvim-neotest/nvim-nio" },
		keys = function()
			local float_opts = {
				position = "center",
				width = math.ceil(
					math.min(vim.o.columns, math.max(80, vim.o.columns - 55))
				),
				height = math.ceil(
					math.min(vim.o.lines, math.max(20, vim.o.lines - 10))
				),
				enter = true,
			}
			-- stylua: ignore
			return {
				{ "<leader>du", function() require("dapui").toggle() end, desc = "Dap ui", },
				{ "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "v" }, },
				{ "<leader>df", function() require("dapui").float_element("repl", float_opts) end, desc = "Repl" },
			}
		end,
		opts = {
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.25 },
						{ id = "console", size = 0.75 },
					},
					size = 20,
					position = "bottom",
				},
			},
			floating = { border = "rounded" },
		},
		config = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			{ "theHamsta/nvim-dap-virtual-text", opts = {} },
		},
		-- stylua: ignore
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
			{ "<F7>", function() require("dap").step_into() end, desc = "Step into" },
			{ "<F8>", function() require("dap").step_over() end, desc = "Step over" },
			{ "<F9>", function() require("dap").continue() end, desc = "Continue" },
			{ "<F21>", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
			{ "<leader>dR", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
			{ "<leader>dT", function() require("dap").terminate() end, desc = "Terminate" },
		},
		config = function()
			vim.api.nvim_set_hl(
				0,
				"DapStoppedLine",
				{ default = true, link = "Visual" }
			)

			local dap = {
				Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
				Breakpoint = { " " },
				BreakpointCondition = { " " },
				BreakpointRejected = { " ", "DiagnosticError" },
				LogPoint = { ".>" },
			}
			for name, sign in pairs(dap) do
				vim.fn.sign_define("Dap" .. name, {
					text = sign[1],
					texthl = sign[2] or "DiagnosticInfo",
					linehl = sign[3],
					numhl = sign[3],
				})
			end
		end,
	},
	{
		"mfussenegger/nvim-dap-python",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			local debugpy_path = os.getenv("PYTHON")
			require("dap-python").setup(debugpy_path)

			local group = vim.api.nvim_create_augroup(
				"python_dap_keymap",
				{ clear = true }
			)
			local function map(lhs, rhx, opts)
				vim.api.nvim_buf_set_keymap(0, "n", lhs, rhx, opts)
			end
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python" },
				-- stylua: ignore
				callback = function(_)
					map("<leader>dm", "<cmd>lua require('dap-python').test_method()<cr>", { desc = "Test method" })
					map("<leader>da", "<cmd>lua require('dap-python').test_class()<cr>", { desc = "Test class" })
					map("<leader>ds", "<cmd>lua require('dap-python').debug_selection()<cr>", { desc = "Debug selection" })
				end,
				group = group,
			})
		end,
	},
}
