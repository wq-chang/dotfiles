return {
	{
		"folke/tokyonight.nvim",
		opts = {
			style = "night",
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			local c = require("tokyonight.colors").setup()
			local hl = function(name, val)
				vim.api.nvim_set_hl(0, name, val)
			end
			hl("BqfPreviewTitle", { link = "FloatBorder" })

			hl("DapUIScope", { fg = c.border_highlight })
			hl("DapUIModifiedValue", { fg = c.border_highlight })
			hl("DapUIDecoration", { fg = c.border_highlight })
			hl("DapUIStoppedThread", { fg = c.border_highlight })
			hl("DapUILineNumber", { fg = c.border_highlight })
			hl("DapUIFloatBorder", { link = "FloatBorder" })
			hl("DapUIBreakpointsPath", { fg = c.border_highlight })
			hl("DapUIStepInto", { fg = c.border_highlight, bg = c.bg_dark })
			hl("DapUIStepOver", { fg = c.border_highlight, bg = c.bg_dark })
			hl("DapUIStepBack", { fg = c.border_highlight, bg = c.bg_dark })
			hl("DapUIStepOut", { fg = c.border_highlight, bg = c.bg_dark })
			hl("DapUIWinSelect", { ctermfg = "Cyan", fg = c.border_highlight })

			hl("DapUIType", { fg = c.purple })
			hl("DapUISource", { fg = c.purple })

			hl("DapUIThread", { fg = c.teal })
			hl("DapUIWatchesValue", { fg = c.teal })
			hl("DapUIBreakpointsInfo", { fg = c.teal })
			hl("DapUIBreakpointsCurrentLine", { fg = c.teal })
			hl("DapUIPlayPause", { fg = c.teal, bg = c.bg_dark })
			hl("DapUIRestart", { fg = c.teal, bg = c.bg_dark })

			hl("DapUIWatchesEmpty", { fg = c.red1 })
			hl("DapUIWatchesError", { fg = c.red1 })
			hl("DapUIStop", { fg = c.red1, bg = c.bg_dark })

			hl("DapUIBreakpointsDisabledLine", { fg = c.fg_gutter })
			hl("DapUIUnavailable", { fg = c.fg_gutter, bg = c.bg_dark })
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
}
