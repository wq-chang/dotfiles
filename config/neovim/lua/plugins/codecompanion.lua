return {
	src = "olimorris/codecompanion.nvim",
	version = vim.version.range("*"),
	after = { "plenary.nvim", "nvim-treesitter" },
	opts = {
		adapters = {
			acp = {
				gemini_cli = function()
					return require("codecompanion.adapters").extend(
						"gemini_cli",
						{
							defaults = {
								auth_method = "oauth-personal",
							},
						}
					)
				end,
			},
		},
		display = {
			action_palette = {
				provider = "fzf_lua",
			},
		},
		interactions = {
			cli = {
				agent = "pi",
				agents = {
					copilot = {
						cmd = "copilot",
						args = {},
						description = "Copilot CLI",
					},
					pi = {
						cmd = "bpi",
						args = {},
						description = "Pi Agent",
					},
				},
			},
			inline = {
				adapter = {
					name = "copilot",
				},
			},
		},
	},
	config = function(opts)
		require("codecompanion").setup(opts)

		-- stylua: ignore start
		vim.keymap.set({ "n", "x" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Code Companion actions" })
		vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionCLI<cr>", { desc = "Code Companion CLI" })
		vim.keymap.set("x", "<leader>ai", "<cmd>CodeCompanionInline<cr>", { desc = "Code Companion inline" })
		vim.keymap.set({ "n", "x" }, "<leader>ap", "<cmd>lua require('codecompanion').cli({ prompt = true })<cr>", { desc = "Code Companion prompt" })
		vim.keymap.set("n", "<leader>at", "<cmd>lua require('codecompanion').toggle()<cr>", { desc = "Toggle Code Companion" })
		-- stylua: ignore end
	end,
}
