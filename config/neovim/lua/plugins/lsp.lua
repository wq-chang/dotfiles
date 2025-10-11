---@param event vim.api.keyset.create_autocmd.callback_args
local function config_lsp_keymap(event)
	local function map(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
	end

	local fzf = require("fzf-lua")
	-- stylua: ignore start
	map("gd", fzf.lsp_definitions, "Goto definition")
	map("gi", fzf.lsp_implementations , "Goto implementation")
	map("gr", function() fzf.lsp_references({ includeDeclaration = false }) end, "Goto references")
	map("<leader>ls", fzf.lsp_document_symbols, "Document symbols")
	map("<leader>la", fzf.lsp_code_actions, "Code action")
	map("<leader>ld", vim.diagnostic.open_float, "Show diagnostic")
	map("<leader>lr", vim.lsp.buf.rename, "Rename")
	map("<leader>lc", vim.lsp.codelens.run, "Codelens")
	map("K", vim.lsp.buf.hover, "Hover Documentation")
	map("gD", vim.lsp.buf.declaration, "Goto declaration")
	map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
	map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
	-- stylua: ignore end
end

---@param event vim.api.keyset.create_autocmd.callback_args
---@param client vim.lsp.Client
local function enable_references_highlight(event, client)
	if client and client.server_capabilities.documentHighlightProvider then
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = event.buf,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = event.buf,
			callback = vim.lsp.buf.clear_references,
		})
	end
end

---@param event vim.api.keyset.create_autocmd.callback_args
---@param client vim.lsp.Client
local function enable_codelens(event, client)
	if client and client.server_capabilities.codeLensProvider then
		vim.lsp.codelens.refresh()
		vim.api.nvim_create_autocmd(
			{ "BufEnter", "BufWritePost", "InsertLeave" },
			{
				buffer = event.buf,
				callback = vim.lsp.codelens.refresh,
			}
		)
	end
end

---@param event vim.api.keyset.create_autocmd.callback_args
---@param client vim.lsp.Client
local function enable_inlay_hints(event, client)
	if client and client.server_capabilities.inlayHintProvider then
		if
			vim.api.nvim_buf_is_valid(event.buf)
			and vim.bo[event.buf].buftype == ""
		then
			vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
		end
	end
end

return {
	"neovim/nvim-lspconfig",
	opts = {
		diagnostic = {
			float = { source = "if_many", border = "rounded" },
			virtual_text = {
				spacing = 4,
				source = "if_many",
			},
			severity_sort = true,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
				},
			},
		},
		servers = {
			basedpyright = {},
			cssls = {},
			eslint = {
				settings = {
					codeActionOnSave = {
						enable = true,
					},
					experimental = {
						useFlatConfig = true,
					},
				},
			},
			gopls = {
				-- experimental feature:
				-- https://github.com/mvdan/gofumpt/issues/2#issuecomment-1934129935
				cmd_env = { GOFUMPT_SPLIT_LONG_LINES = "on" },
				settings = {
					gopls = {
						gofumpt = true,
						codelenses = {
							test = true,
							vulncheck = true,
						},
						hints = {
							assignVariableTypes = false,
							compositeLiteralFields = false,
							compositeLiteralTypes = false,
							constantValues = false,
							functionTypeParameters = false,
							parameterNames = false,
							rangeVariableTypes = false,
						},
						usePlaceholders = true,
						directoryFilters = {
							"-.git",
							"-.vscode",
							"-.idea",
							"-.vscode-test",
							"-node_modules",
						},
						semanticTokens = true,
						vulncheck = "Imports",
					},
				},
			},
			jsonls = { init_options = { provideFormatter = false } },
			lua_ls = {
				settings = {
					Lua = { completion = { callSnippet = "Replace" } },
				},
			},
			nixd = {},
			ruff = {},
			terraformls = {},
			ts_ls = {},
		},
	},
	config = function(_, opts)
		vim.diagnostic.config(opts.diagnostic)

		-- stylua: ignore
		vim.keymap.set( "n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "Lsp info" })
		vim.api.nvim_del_keymap("n", "gra")
		vim.api.nvim_del_keymap("n", "gri")
		vim.api.nvim_del_keymap("n", "grn")
		vim.api.nvim_del_keymap("n", "grr")
		vim.api.nvim_del_keymap("n", "grt")

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				config_lsp_keymap(event)

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client then
					enable_references_highlight(event, client)
					enable_codelens(event, client)
					enable_inlay_hints(event, client)
				end
			end,
		})

		for server_name, server_config in pairs(opts.servers) do
			vim.lsp.config(server_name, server_config)
			vim.lsp.enable(server_name)
		end
	end,
}
