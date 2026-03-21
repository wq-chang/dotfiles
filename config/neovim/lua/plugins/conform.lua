local function generate_formatter_by_ft()
	local ft_formatter = {
		go = { "golangci-lint" },
		java = { "google-java-format" },
		lua = { "stylua" },
		nix = { "nixfmt" },
		python = { "ruff_organize_imports", "ruff_format" },
		sql = { "sqlfluff" },
		xml = { "xmllint" },
	}

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

	for formatter, fts in pairs(formatter_ft) do
		for _, ft in ipairs(fts) do
			if not ft_formatter[ft] then
				ft_formatter[ft] = {}
			end
			table.insert(ft_formatter[ft], formatter)
		end
	end

	return ft_formatter
end

local function create_disable_autoformat_command()
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
end

local function create_enable_autoformat_command()
	vim.api.nvim_create_user_command("FormatEnable", function()
		vim.b.disable_autoformat = false
		vim.g.disable_autoformat = false
	end, {
		desc = "Re-enable autoformat-on-save",
	})
end

local function format_on_save(bufnr)
	if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
		return
	end

	return {
		timeout_ms = 500,
		lsp_format = "fallback",
	}
end

return {
	"stevearc/conform.nvim",
	opts = function()
		return {
			format_on_save = format_on_save,
			formatters_by_ft = generate_formatter_by_ft(),
		}
	end,
	config = function(_, opts)
		require("conform").setup(opts)
		create_disable_autoformat_command()
		create_enable_autoformat_command()
		vim.keymap.set("n", "<leader>cf", function()
			require("conform").format()
		end, { desc = "Format code" })
	end,
}
