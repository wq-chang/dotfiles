return {
	{
		"folke/tokyonight.nvim",
		opts = {
			style = "night",
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			local c = require("tokyonight.colors").setup()
			local hl = function(name, val)
				vim.api.nvim_set_hl(0, name, val)
			end
			hl("InactiveText", { fg = c.dark3, bg = c.bg_float })

			hl("DapUIScope", { fg = c.border_highlight })
			hl("DapUIModifiedValue", { fg = c.border_highlight })
			hl("DapUIDecoration", { fg = c.border_highlight })
			hl("DapUIStoppedThread", { fg = c.border_highlight })
			hl("DapUILineNumber", { fg = c.border_highlight })
			hl("DapUIFloatBorder", { fg = c.border_highlight, bg = c.bg_float })
			hl("DapUIBreakpointsPath", { fg = c.border_highlight })
			hl("DapUIStepInto", { fg = c.border_highlight, bg = c.bg_float })
			hl("DapUIStepOver", { fg = c.border_highlight, bg = c.bg_float })
			hl("DapUIStepBack", { fg = c.border_highlight, bg = c.bg_float })
			hl("DapUIStepOut", { fg = c.border_highlight, bg = c.bg_float })
			hl("DapUIWinSelect", { ctermfg = "Cyan", fg = c.border_highlight })

			hl("DapUIType", { fg = c.purple })
			hl("DapUISource", { fg = c.purple })

			hl("DapUIThread", { fg = c.teal })
			hl("DapUIWatchesValue", { fg = c.teal })
			hl("DapUIBreakpointsInfo", { fg = c.teal })
			hl("DapUIBreakpointsCurrentLine", { fg = c.teal })
			hl("DapUIPlayPause", { fg = c.teal, bg = c.bg_float })
			hl("DapUIRestart", { fg = c.teal, bg = c.bg_float })

			hl("DapUIWatchesEmpty", { fg = c.red1 })
			hl("DapUIWatchesError", { fg = c.red1 })
			hl("DapUIStop", { fg = c.red1, bg = c.bg_float })

			hl("DapUIBreakpointsDisabledLine", { fg = "#424242" })
			hl("DapUIUnavailable", { fg = "#424242" })
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
}
