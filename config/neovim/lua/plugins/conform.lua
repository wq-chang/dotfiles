return {
	{
		"stevearc/conform.nvim",
		opts = function()
			local formatter_ft = {
				prettierd = {
					"css",
					"scss",
					"javascript",
					"json",
					"markdown",
					"typescript",
				},
				shfmt = { "sh", "zsh" },
			}
			local ft_formatter = {
				java = { "google-java-format" },
				lua = { "stylua" },
				nix = { "nixfmt" },
				python = { "black", "isort" },
			}
			local function formatter_ft_to_ft_formmater(formatter_filetype)
				local tbl = {}
				for formatter, filetypes in pairs(formatter_filetype) do
					for _, filetype in ipairs(filetypes) do
						tbl[filetype] = { formatter }
					end
				end
				return tbl
			end
			return {
				format_on_save = {
					timeout_ms = 3000,
					async = false,
					quiet = false,
					lsp_fallback = true,
				},
				formatters_by_ft = vim.tbl_extend(
					"error",
					ft_formatter,
					formatter_ft_to_ft_formmater(formatter_ft)
				),
			}
		end,
	},
}
