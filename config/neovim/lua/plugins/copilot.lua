return {
	{
		"copilotlsp-nvim/copilot-lsp",
		init = function()
			vim.g.copilot_nes_debounce = 500
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		dependencies = {
			"copilotlsp-nvim/copilot-lsp",
		},
		opts = {
			panel = {
				enabled = false,
			},
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = false,
					accept_word = false,
					accept_line = false,
					dismiss = "<M-BS>",
				},
			},
			nes = {
				enabled = true,
				auto_trigger = true,
			},
			server = {
				type = "binary",
				custom_server_filepath = os.getenv("COPILOT_LSP"),
			},
		},
		config = function(_, opts)
			require("copilot").setup(opts)

			vim.keymap.set("i", "<tab>", function()
				local suggestion = require("copilot.suggestion")
				if suggestion.is_visible() then
					suggestion.accept()
				else
					return "<tab>"
				end
			end)

			vim.keymap.set("n", "<tab>", function()
				local bufnr = vim.api.nvim_get_current_buf()
				local state = vim.b[bufnr].nes_state
				if state then
					local nes = require("copilot-lsp.nes")
					local _ = nes.walk_cursor_start_edit()
						or (
							nes.apply_pending_nes()
							and nes.walk_cursor_end_edit()
						)
					return nil
				else
					return "<tab>"
				end
			end, { desc = "Accept Copilot NES suggestion", expr = true })
		end,
	},
}
