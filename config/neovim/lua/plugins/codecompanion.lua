return {
	"olimorris/codecompanion.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
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
	},
}
