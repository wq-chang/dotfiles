return {
	{
		src = "theHamsta/nvim-dap-virtual-text",
		after = { "nvim-dap" },
		opts = {},
	},
	{
		src = "rcarriga/nvim-dap-ui",
		after = { "nvim-nio", "nvim-dap" },
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
		config = function(opts)
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
			-- stylua: ignore start
			vim.keymap.set("n", "<leader>du", function() dapui.toggle() end, { desc = "Dap ui" })
			vim.keymap.set({ "n", "v" }, "<leader>de", function() dapui.eval() end, { desc = "Eval" })
			vim.keymap.set("n", "<leader>df", function() dapui.float_element("repl", float_opts) end, { desc = "Repl" })
			-- stylua: ignore end
		end,
	},
	{
		src = "mfussenegger/nvim-dap",
		config = function()
			vim.api.nvim_set_hl(
				0,
				"DapStoppedLine",
				{ default = true, link = "Visual" }
			)

			local signs = {
				Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
				Breakpoint = { " " },
				BreakpointCondition = { " ", "DapBreakpointCondition" },
				BreakpointRejected = { " ", "DiagnosticError" },
				LogPoint = { ".>" },
			}
			for name, sign in pairs(signs) do
				vim.fn.sign_define("Dap" .. name, {
					text = sign[1],
					texthl = sign[2] or "DiagnosticInfo",
					linehl = sign[3],
					numhl = sign[3],
				})
			end

			-- stylua: ignore start
			vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
			vim.keymap.set("n", "<F7>", function() require("dap").step_into() end, { desc = "Step into" })
			vim.keymap.set("n", "<F8>", function() require("dap").step_over() end, { desc = "Step over" })
			vim.keymap.set("n", "<F9>", function() require("dap").continue() end, { desc = "Continue" })
			vim.keymap.set("n", "<F21>", function() require("dap").run_to_cursor() end, { desc = "Run to cursor" })
			vim.keymap.set("n", "<leader>dR", function() require("dap").repl.toggle() end, { desc = "Toggle REPL" })
			vim.keymap.set("n", "<leader>dT", function() require("dap").terminate() end, { desc = "Terminate" })
			-- stylua: ignore end
		end,
	},
	{
		src = "mfussenegger/nvim-dap-python",
		after = { "nvim-dap" },
		config = function()
			require("dap-python").setup("python")

			local group = vim.api.nvim_create_augroup(
				"python_dap_keymap",
				{ clear = true }
			)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python" },
				callback = function(_)
					local function map(lhs, rhs, opts)
						opts = opts or {}
						opts.buffer = 0
						vim.keymap.set("n", lhs, rhs, opts)
					end
					-- stylua: ignore start
					map("<leader>dm", "<cmd>lua require('dap-python').test_method()<cr>", { desc = "Test method" })
					map("<leader>da", "<cmd>lua require('dap-python').test_class()<cr>", { desc = "Test class" })
					map("<leader>ds", "<cmd>lua require('dap-python').debug_selection()<cr>", { desc = "Debug selection" })
					-- stylua: ignore end
				end,
				group = group,
			})
		end,
	},
	{
		src = "leoluz/nvim-dap-go",
		after = { "nvim-dap" },
		config = function()
			local go_utils = require("utils.go")
			local dap_go = require("dap-go")

			dap_go.setup({
				delve = {
					build_flags = go_utils.current_test_build_flags,
				},
			})

			local group = vim.api.nvim_create_augroup(
				"golang_dap_keymap",
				{ clear = true }
			)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "go" },
				callback = function(_)
					local function map(lhs, rhs, opts)
						opts = opts or {}
						opts.buffer = 0
						vim.keymap.set("n", lhs, rhs, opts)
					end
					map("<leader>dm", function()
						dap_go.debug_test(go_utils.current_debug_test_config())
					end, { desc = "Test method" })
				end,
				group = group,
			})
		end,
	},
}
