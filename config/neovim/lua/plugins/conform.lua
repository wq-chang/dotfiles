return {
	"stevearc/conform.nvim",
	opts = function()
		local formatter_ft = {
			prettier = {
				"css",
				"scss",
				"javascript",
				"json",
				"markdown",
				"typescript",
				"typescriptreact",
				"yaml",
			},
			shfmt = { "sh", "zsh" },
		}
		local ft_formatter = {
			go = { "golines" },
			java = { "google-java-format" },
			lua = { "stylua" },
			nix = { "nixfmt" },
			python = { "ruff_organize_imports", "ruff_format" },
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
			format_on_save = function(bufnr)
				if
					vim.g.disable_autoformat
					or vim.b[bufnr].disable_autoformat
				then
					return
				end

				return {
					timeout_ms = 3000,
					async = false,
					quiet = false,
					lsp_fallback = true,
				}
			end,
			formatters_by_ft = vim.tbl_extend(
				"error",
				ft_formatter,
				formatter_ft_to_ft_formmater(formatter_ft)
			),
		}
	end,
	config = function(_, opts)
		require("conform").setup(opts)

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- FormatDisable! will disable formatting just for this buffer
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})
		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat-on-save",
		})
	end,
}
