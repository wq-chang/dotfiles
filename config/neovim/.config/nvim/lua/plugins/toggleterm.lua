return {
	{
		"akinsho/toggleterm.nvim",
		priority = 1,
		opts = function()
			local float_border =
				vim.api.nvim_get_hl(0, { name = "FloatBorder" })
			print(float_border.fg)
			return {
				direction = "float",
				float_opts = {
					border = "curved",
				},
				highlights = {
					FloatBorder = {
						guifg = ("#%06x"):format(float_border.fg),
						guibg = ("#%06x"):format(float_border.bg),
					},
				},
			}
		end,
		config = function(_, opts)
			require("toggleterm").setup(opts)
			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

			local function lazygit_toggle()
				lazygit:toggle()
			end

			vim.keymap.set(
				"n",
				"<leader>gg",
				lazygit_toggle,
				{ desc = "Open Lazygit", noremap = true, silent = true }
			)
		end,
	},
}
