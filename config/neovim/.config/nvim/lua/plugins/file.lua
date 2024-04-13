return {
	{
		"echasnovski/mini.files",
		opts = {
			mappings = {
				go_in_plus = "<cr>",
			},
			windows = {
				preview = true,
			},
		},
		config = function(_, opts)
			require("mini.files").setup(opts)
			local git_utils = require("utils.git")
			local function open_from_root()
				local cwd = git_utils.get_git_root()
				require("mini.files").open(cwd)
			end
			vim.api.nvim_set_hl(0, "MiniFilesTitle", { link = "StatusLineNC" })

			vim.keymap.set(
				"n",
				"<leader>fe",
				"<cmd>lua MiniFiles.open()<cr>",
				{ desc = "Open file explorer" }
			)
			vim.keymap.set(
				"n",
				"<leader>fg",
				open_from_root,
				{ desc = "Open file explorer" }
			)
		end,
	},
}
