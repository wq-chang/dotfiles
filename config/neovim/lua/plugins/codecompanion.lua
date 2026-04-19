return {
	"olimorris/codecompanion.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		-- stylua: ignore start
		{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "x" }, desc = "Code Companion actions" },
		{ "<leader>ac", "<cmd>CodeCompanionCLI<cr>", desc = "Code Companion CLI" },
		{ "<leader>ai", "<cmd>CodeCompanionInline<cr>", mode = "x", desc = "Code Companion inline" },
		{ "<leader>ap", "<cmd>lua require('codecompanion').cli({ prompt = true })<cr>", mode = { "n", "x" }, desc = "Code Companion prompt" },
		{ "<leader>at", "<cmd>lua require('codecompanion').toggle()<cr>", desc = "Toggle Code Companion" },
		-- stylua: ignore end
	},
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
				agent = "copilot",
				agents = {
					copilot = {
						cmd = "copilot",
						args = {},
						description = "Copilot CLI",
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
}
