local table_utils = require("utils/table")

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

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			{
				"williamboman/mason-lspconfig.nvim",
			},
			{ "j-hui/fidget.nvim", opts = {} },
			-- { "folke/neodev.nvim", opts = {} },
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

					map(
						"gd",
						require("telescope.builtin").lsp_definitions,
						"Goto definition"
					)

					map(
						"gr",
						require("telescope.builtin").lsp_references,
						"Goto references"
					)

					map(
						"gi",
						require("telescope.builtin").lsp_implementations,
						"Goto implementation"
					)

					-- map(
					-- 	"<leader>D",
					-- 	require("telescope.builtin").lsp_type_definitions,
					-- 	"Type [D]efinition"
					-- )

					map(
						"<leader>ls",
						require("telescope.builtin").lsp_document_symbols,
						"Document symbols"
					)

					-- -- Fuzzy find all the symbols in your current workspace.
					-- --  Similar to document symbols, except searches over your entire project.
					-- map(
					-- 	"<leader>ws",
					-- 	require("telescope.builtin").lsp_dynamic_workspace_symbols,
					-- 	"[W]orkspace [S]ymbols"
					-- )

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>lr", vim.lsp.buf.rename, "Rename")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>la", vim.lsp.buf.code_action, "Code action")

					-- Opens a popup that displays documentation about the word under your cursor
					--  See `:help K` for why this keymap.
					map("K", vim.lsp.buf.hover, "Hover Documentation")

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
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

			for server_name, _ in pairs(servers) do
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
			end
		end,
		get_wanted_packages = function()
			return table_utils.get_table_keys(servers)
		end,
	},
}
