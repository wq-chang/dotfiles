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
	-- {
	-- 	"stevearc/oil.nvim",
	-- 	opts = {
	-- 		keymaps = {
	-- 			["g?"] = "actions.show_help",
	-- 			["l"] = "actions.select",
	-- 			["<C-s>"] = "actions.select_vsplit",
	-- 			["<C-h>"] = "actions.select_split",
	-- 			["<C-t>"] = "actions.select_tab",
	-- 			["<C-p>"] = "actions.preview",
	-- 			q = "actions.close",
	-- 			["<C-l>"] = "actions.refresh",
	-- 			["h"] = "actions.parent",
	-- 			["_"] = "actions.open_cwd",
	-- 			["`"] = "actions.cd",
	-- 			["~"] = "actions.tcd",
	-- 			["gs"] = "actions.change_sort",
	-- 			["gx"] = "actions.open_external",
	-- 			["g."] = "actions.toggle_hidden",
	-- 			["g\\"] = "actions.toggle_trash",
	-- 		},
	-- 		use_default_keymaps = false,
	-- 		view_options = {
	-- 			show_hidden = true,
	-- 		},
	-- 		win_options = {
	-- 			winbar = "%{v:lua.require('oil').get_current_dir()}",
	-- 		},
	-- 	},
	-- },
}
