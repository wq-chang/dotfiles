return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
		keys = {
			{
				"<tab>",
				function()
					return require("luasnip").jumpable(1)
							and "<Plug>luasnip-jump-next"
						or "<tab>"
				end,
				expr = true,
				silent = true,
				mode = "i",
			},
			{
				"<tab>",
				function()
					require("luasnip").jump(1)
				end,
				mode = "s",
			},
			{
				"<s-tab>",
				function()
					require("luasnip").jump(-1)
				end,
				mode = { "i", "s" },
			},
		},
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"onsails/lspkind.nvim",
		},
		opts = function()
			vim.api.nvim_set_hl(
				0,
				"CmpGhostText",
				{ link = "Comment", default = true }
			)
			local cmp = require("cmp")
			local defaults = require("cmp.config.default")()
			local lspkind = require("lspkind")
			return {
				auto_brackets = {},
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item({
						behavior = cmp.SelectBehavior.Insert,
					}),
					["<C-p>"] = cmp.mapping.select_prev_item({
						behavior = cmp.SelectBehavior.Insert,
					}),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<S-CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
					["<C-CR>"] = function(fallback)
						cmp.abort()
						fallback()
					end,
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						menu = {
							buffer = "[Buffer]",
							nvim_lsp = "[LSP]",
							luasnip = "[LuaSnip]",
							nvim_lua = "[Lua]",
							latex_symbols = "[Latex]",
						},
						maxwidth = 50,
						ellipsis_char = "...",
						show_labelDetails = true,
						before = function(_, vim_item)
							return vim_item
						end,
					}),
				},
				experimental = {
					ghost_text = {
						hl_group = "CmpGhostText",
					},
				},
				sorting = defaults.sorting,
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = {
						border = "rounded",
						scrollbar = "║",
						winhighlight = "BorderFloat:FloatBorder",
					},
					documentation = {
						border = "rounded",
						scrollbar = "",
						winhighlight = "BorderFloat:FloatBorder",
					},
				},
			}
		end,
		config = function(_, opts)
			for _, source in ipairs(opts.sources) do
				source.group_index = source.group_index or 1
			end
			local cmp = require("cmp")
			local Kind = cmp.lsp.CompletionItemKind
			cmp.setup(opts)
			cmp.event:on("confirm_done", function(event)
				if
					not vim.tbl_contains(
						opts.auto_brackets or {},
						vim.bo.filetype
					)
				then
					return
				end
				local entry = event.entry
				local item = entry:get_completion_item()
				if
					vim.tbl_contains({ Kind.Function, Kind.Method }, item.kind)
				then
					local keys = vim.api.nvim_replace_termcodes(
						"()<left>",
						false,
						false,
						true
					)
					vim.api.nvim_feedkeys(keys, "i", true)
				end
			end)
		end,
	},
}
