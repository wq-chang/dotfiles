return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			-- Lsp UI config
			local signs = {
				Error = "󰅚 ",
				Warn = "󰀪 ",
				Hint = "󰌶 ",
				Info = "󰋽 ",
			}
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end
			vim.diagnostic.config({
				float = { source = "if_many", border = "rounded" },
			})
			-- stylua: ignore
			vim.keymap.set( "n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "Lsp info" })
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup(
					"lsp-attach",
					{ clear = true }
				),
				callback = function(event)
					local function map(keys, func, desc)
						vim.keymap.set(
							"n",
							keys,
							func,
							{ buffer = event.buf, desc = desc }
						)
					end

					local module_utils = require("utils.module")
					local fzf = module_utils.try_require("fzf-lua")
					-- stylua: ignore
					if fzf then
						map("gd", fzf.lsp_definitions, "Goto definition")
						map("gi", fzf.lsp_implementations , "Goto implementation")
						map("gr", function() fzf.lsp_references({ includeDeclaration = false }) end, "Goto references")
						map("<leader>ls", fzf.lsp_document_symbols, "Document symbols")
						map("<leader>la", fzf.lsp_code_actions, "Code action")
					end

					-- stylua: ignore
					map("<leader>ld", vim.diagnostic.open_float, "Show diagnostic")
					map("<leader>lr", vim.lsp.buf.rename, "Rename")
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "Goto declaration")
					map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
					map("]d", vim.diagnostic.goto_next, "Next diagnostic")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client =
						vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client.server_capabilities.documentHighlightProvider
					then
						vim.api.nvim_create_autocmd(
							{ "CursorHold", "CursorHoldI" },
							{
								buffer = event.buf,
								callback = vim.lsp.buf.document_highlight,
							}
						)
						vim.api.nvim_create_autocmd(
							{ "CursorMoved", "CursorMovedI" },
							{
								buffer = event.buf,
								callback = vim.lsp.buf.clear_references,
							}
						)
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local mu = require("utils.module")
			local cmp_nvim_lsp = mu.try_require("cmp_nvim_lsp")
			if cmp_nvim_lsp then
				capabilities = vim.tbl_deep_extend(
					"force",
					capabilities,
					cmp_nvim_lsp.default_capabilities()
				)
			end

			local servers = {
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
				jsonls = { init_options = { provideFormatter = false } },
				lua_ls = {
					settings = {
						Lua = { completion = { callSnippet = "Replace" } },
					},
				},
				nixd = {},
				pyright = {},
				terraformls = {},
				tsserver = {},
			}

			for server_name in pairs(servers) do
				local server = servers[server_name] or {}
				server.capabilities = vim.tbl_deep_extend(
					"force",
					{},
					capabilities,
					server.capabilities or {}
				)
				require("lspconfig")[server_name].setup(server)
			end
		end,
	},
}
