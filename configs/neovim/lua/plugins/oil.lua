return {
	{
		"stevearc/oil.nvim",
		opts = function()
			local oil = require("oil")
			local git_utils = require("utils.git")
			local function select_or_preview()
				local entry = oil.get_cursor_entry()
				if entry and entry.type == "file" then
					oil.open_preview()
					return
				end
				oil.select()
			end
			return {
				default_file_explorer = true,
				keymaps = {
					["g?"] = "actions.show_help",
					["l"] = select_or_preview,
					["<CR>"] = "actions.select",
					["<C-v>"] = "actions.select_vsplit",
					["<C-s>"] = "actions.select_split",
					["<C-p>"] = "actions.preview",
					q = "actions.close",
					["<C-r>"] = "actions.refresh",
					["h"] = "actions.parent",
					["_"] = "actions.open_cwd",
					["`"] = "actions.cd",
					["~"] = "actions.tcd",
					["gs"] = "actions.change_sort",
					["gx"] = "actions.open_external",
					["g."] = "actions.toggle_hidden",
					["g\\"] = "actions.toggle_trash",
					["<BS>"] = oil.discard_all_changes,
				},
				use_default_keymaps = false,
				view_options = {
					is_hidden_file = function(name, _)
						local ignored_files =
							git_utils.get_git_ignored_files_in(
								oil.get_current_dir()
							)
						table.insert(ignored_files, "..")
						return vim.tbl_contains(ignored_files, name)
					end,
				},
				win_options = {
					winbar = "%{v:lua.require('oil').get_current_dir()}",
				},
			}
		end,
		config = function(_, opts)
			local oil = require("oil")
			oil.setup(opts)
			local git_utils = require("utils.git")
			local function open_from_root()
				local cwd = git_utils.get_git_root()
				oil.open(cwd)
			end
			vim.keymap.set(
				"n",
				"<leader>fe",
				"<cmd>Oil<cr>",
				{ desc = "Open file explorer" }
			)
			vim.keymap.set(
				"n",
				"<leader>fg",
				open_from_root,
				{ desc = "Open file explorer from git root" }
			)
		end,
	},
}
