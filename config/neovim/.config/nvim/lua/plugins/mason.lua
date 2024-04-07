local mason_mapper = require("customs/mason-mapper")
return {
	{ "williamboman/mason.nvim", opts = {} },
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			{ "williamboman/mason-lspconfig.nvim", optional = true },
			{ "neovim/nvim-lspconfig", optional = true },
			{ "stevearc/conform.nvim", optional = true },
			{ "mfussenegger/nvim-lint", optional = true },
		},
		config = function()
			local opts = {
				ensure_installed = mason_mapper.get_ensure_installed(),
			}
			require("mason-tool-installer").setup(opts)
		end,
	},
}
