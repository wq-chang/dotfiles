return {
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		opts = {
			lsp = {
				progress = {
					enabled = false,
				},
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			messages = {
				enabled = false,
			},
			notify = {
				enabled = false,
			},
			presets = {
				bottom_search = false,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
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
						right_padding = 2,
					},
				},
				lualine_b = {
					"branch",
					"diff",
				},
				lualine_c = {
					"%=",
					"filename",
					{
						"diagnostics",
						sources = { "nvim_lsp", "nvim_diagnostic" },
						sections = { "error", "warn", "info", "hint" },
						diagnostics_color = {
							error = "DiagnosticError",
							warn = "DiagnosticWarn",
							info = "DiagnosticInfo",
							hint = "DiagnosticHint",
						},
					},
				},
				lualine_x = {},
				lualine_y = { "filetype", "progress" },
				lualine_z = {
					{
						"location",
						separator = { left = "", right = "" },
						left_padding = 2,
					},
				},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					"%=",
					{
						"filename",
					},
				},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		},
	},
}
