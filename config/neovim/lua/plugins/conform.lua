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
				javascript = { "prettierd" },
				lua = { "stylua" },
				json = { "prettierd" },
				jsonc = { "prettierd" },
				markdown = { "prettierd" },
				nix = { "nixfmt" },
				python = { "black", "isort" },
				sh = { "shfmt" },
				typescript = { "prettierd" },
				zsh = { "shfmt" },
			},
		},
	},
}
