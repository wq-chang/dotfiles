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
			local files = require("mini.files")
			files.setup(opts)
			local git_utils = require("utils.git")
			local function open_from_root()
				local cwd = git_utils.get_git_root()
				files.open(cwd)
			end
			local function open_from_cur_file_dir()
				local cwd = vim.api.nvim_buf_get_name(0)
				if vim.fn.filereadable(cwd) == 0 then
					cwd = git_utils.get_git_root()
				end
				files.open(cwd)
			end
			vim.api.nvim_set_hl(0, "MiniFilesTitle", { link = "InactiveText" })

			vim.keymap.set(
				"n",
				"<leader>fe",
				open_from_cur_file_dir,
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
