return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			{ "williamboman/mason-lspconfig.nvim" },
			{ "j-hui/fidget.nvim", opts = {}, config = true },
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			vim.diagnostic.config({
				float = { border = "rounded" },
			})
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup(
					"lsp-attach",
					{ clear = true }
				),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set(
							"n",
							keys,
							func,
							{ buffer = event.buf, desc = desc }
						)
					end

					local module_utils = require("utils.module")
					local tls_builtin =
						module_utils.try_require("telescope.builtin")
					if tls_builtin then
						map(
							"gd",
							tls_builtin.lsp_definitions,
							"Goto definition"
						)
						map("gr", tls_builtin.lsp_references, "Goto references")
						map(
							"gi",
							tls_builtin.lsp_implementations,
							"Goto implementation"
						)
						map(
							"<leader>ls",
							tls_builtin.lsp_document_symbols,
							"Document symbols"
						)
					end

					map("<leader>la", vim.lsp.buf.code_action, "Code action")
					map(
						"<space>ld",
						vim.diagnostic.open_float,
						"Show diagnostic"
					)
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

			local mapper = require("customs/mason-mapper")
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
			}
			mapper.add_all_ensure_installed(vim.tbl_keys(servers))

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend(
							"force",
							{},
							capabilities,
							server.capabilities or {}
						)
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
}
