local table_utils = require("utils/table")
local formatters_by_ft = {
	lua = { "stylua" },
}

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
			formatters_by_ft = formatters_by_ft,
		},
		config = function(_, opts)
			require("conform").setup(opts)
		end,
		get_wanted_packages = function()
			local formatter_list =
				table_utils.get_table_values(formatters_by_ft)
			return table_utils.flat_map(formatter_list)
		end,
	},
}
