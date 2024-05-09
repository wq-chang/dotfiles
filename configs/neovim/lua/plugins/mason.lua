local mason_mapper = require("customs/mason-mapper")
return {
	{ "williamboman/mason.nvim", opts = { ui = { border = "rounded" } } },
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		priority = 1,
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			local opts = {
				ensure_installed = mason_mapper.ensure_installed,
			}
			require("mason-tool-installer").setup(opts)
		end,
	},
}
