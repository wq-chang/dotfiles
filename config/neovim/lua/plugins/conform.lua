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
				java = { "google-java-format" },
				lua = { "stylua" },
				json = { "prettierd" },
				markdown = { "prettierd" },
				nix = { "nixfmt" },
				python = { "black", "isort" },
				sh = { "shfmt" },
				zsh = { "shfmt" },
			},
		},
	},
}
