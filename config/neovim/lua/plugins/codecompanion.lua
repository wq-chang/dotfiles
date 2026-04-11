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
		{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Code Companion chat" },
		{ "<leader>aC", "<cmd>CodeCompanionChat<cr>", desc = "Create Code Companion chat" },
		{ "<leader>ai", "<cmd>CodeCompanionInline<cr>", mode = "x", desc = "Code Companion inline" },
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
			chat = {
				adapter = {
					name = "copilot_acp",
					model = "gpt-5-mini",
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
