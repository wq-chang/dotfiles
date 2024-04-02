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

					local tls_builtin = require("telescope.builtin")
					map("gd", tls_builtin.lsp_definitions, "Goto definition")
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
					map("<leader>lr", vim.lsp.buf.rename, "Rename")
					map("<leader>la", vim.lsp.buf.code_action, "Code action")
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "Goto declaration")

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

			-- -- LSP servers and clients are able to communicate to each other what features they support.
			-- --  By default, Neovim doesn't support everything that is in the LSP specification.
			-- --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			-- --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			-- local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- capabilities = vim.tbl_deep_extend(
			-- 	"force",
			-- 	capabilities,
			-- 	require("cmp_nvim_lsp").default_capabilities()
			-- )

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
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for tsserver)
						-- server.capabilities = vim.tbl_deep_extend(
						-- 	"force",
						-- 	{},
						-- 	capabilities,
						-- 	server.capabilities or {}
						-- )
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
}
