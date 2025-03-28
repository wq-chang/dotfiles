return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = function()
		local mid_sec = {
			"%=",
			{
				"filetype",
				icon_only = true,
				padding = { right = 0 },
			},
			{
				"filename",
				padding = { left = 1 },
				symbols = {
					modified = "󰏫 ",
					readonly = "󰗚 ",
				},
			},
			"diagnostics",
		}
		return {
			options = {
				theme = "tokyonight",
				component_separators = "",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = {
					{
						"mode",
						separator = { left = "", right = "" },
					},
				},
				lualine_b = {
					"branch",
					{
						"diff",
						symbols = {
							added = " ",
							modified = " ",
							removed = " ",
						},
					},
				},
				lualine_c = mid_sec,
				lualine_x = {},
				lualine_y = { "fileformat", "encoding" },
				lualine_z = {
					{
						"progress",
						padding = { right = 1 },
					},
					{
						"location",
						padding = { left = 0 },
						separator = { left = "", right = "" },
					},
				},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = mid_sec,
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		}
	end,
}
