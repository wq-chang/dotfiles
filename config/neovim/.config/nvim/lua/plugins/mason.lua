local mason_mapper = require("customs/mason_mapper")
return {
	{ "williamboman/mason.nvim", config = true },
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = { ensure_installed = mason_mapper.get_all_wanted_packages() },
		config = function(_, opts)
			require("mason-tool-installer").setup(opts)
		end,
	},
}
