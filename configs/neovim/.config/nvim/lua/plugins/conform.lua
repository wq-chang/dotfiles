return {
	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = {
				timeout_ms = 3000,
				async = false,
				quiet = false,
				lsp_fallback = true,
			},
			formatters_by_ft = {
				lua = { "stylua" },
				json = { "prettierd" },
				sh = { "shfmt" },
				zsh = { "shfmt" },
			},
		},
	},
}