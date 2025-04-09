local function create_icon_configs(ctx)
	local icon = ctx.kind_icon
	if vim.tbl_contains({ "Path" }, ctx.source_name) then
		local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
		if dev_icon then
			icon = dev_icon
		end
	else
		icon = require("lspkind").symbolic(ctx.kind, {
			mode = "symbol",
		})
	end

	return icon .. ctx.icon_gap
end

local function create_hl_configs(ctx)
	local hl = ctx.kind_hl
	if vim.tbl_contains({ "Path" }, ctx.source_name) then
		local dev_icon, dev_hl =
			require("nvim-web-devicons").get_icon(ctx.label)
		if dev_icon then
			hl = dev_hl
		end
	end
	return hl
end

return {
	"saghen/blink.cmp",
	version = "*",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"onsails/lspkind.nvim",
	},
	opts = {
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			documentation = {
				auto_show = true,
				window = { border = "rounded" },
			},
			menu = {
				border = "rounded",
				draw = {
					columns = {
						{ "label" },
						{ "kind_icon", "kind", gap = 1 },
						{ "source_id", "label_description" },
					},
					components = {
						label_description = { highlight = "Comment" },
						kind_icon = {
							text = create_icon_configs,
							highlight = create_hl_configs,
						},
						source_id = {
							text = function(ctx)
								return "[" .. ctx.source_name .. "]"
							end,
							highlight = "Comment",
						},
					},
				},
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
		keymap = {
			preset = "enter",
		},
		signature = { window = { border = "rounded" } },
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
	},
	opts_extend = { "sources.default" },
}
