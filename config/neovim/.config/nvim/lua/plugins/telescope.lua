return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = vim.fn.executable("make") == 1 and "make"
					or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release "
						.. "&& cmake --build build --config Release "
						.. "&& cmake --install build --prefix build",
				enabled = vim.fn.executable("make") == 1
					or vim.fn.executable("cmake") == 1,
			},
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local themes = require("telescope.themes")
			telescope.setup({
				defaults = {
					layout_strategy = "vertical",
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["<up>"] = actions.cycle_history_prev,
							["<down>"] = actions.cycle_history_next,
							["<C-s>"] = actions.select_horizontal,
						},
					},
				},
				pickers = {
					find_files = {
						hidden = true,
					},
					buffers = {
						mappings = {
							i = {
								["<C-x>"] = actions.delete_buffer,
							},
						},
					},
				},
				extensions = {
					live_grep_args = {
						vimgrep_arguments = {
							"rg",
							"--color=never",
							"--no-heading",
							"--with-filename",
							"--line-number",
							"--column",
							"--smart-case",
							"--hidden",
						},
						mappings = {
							i = {
								["<C-k>"] = require(
									"telescope-live-grep-args.actions"
								).quote_prompt(),
							},
						},
					},
					["ui-select"] = {
						themes.get_dropdown({}),
					},
				},
			})
			telescope.load_extension("fzf")
			telescope.load_extension("ui-select")
			telescope.load_extension("live_grep_args")

			local git_utils = require("utils.git")
			local function find_files_from_git_root()
				local cwd = git_utils.get_git_root()
				require("telescope.builtin").find_files({ cwd = cwd })
			end

			local function live_grep_from_git_root()
				local cwd = git_utils.get_git_root()
				require("telescope").extensions.live_grep_args.live_grep_args({
					cwd = cwd,
				})
			end
			local function map(keys, func, desc, is_local_func)
				vim.keymap.set(
					"n",
					"<leader>" .. keys,
					is_local_func and func or ("<cmd>" .. func .. "<cr>"),
					{ desc = desc }
				)
			end
			map(
				"b",
				"Telescope buffers sort_mru=true sort_lastused=true",
				"Buffers"
			)
			map("/", live_grep_from_git_root, "Grep root dir", true)
			map(".", "Telescope command_history", "Command history")
			map("fc", "Telescope commands", "Find commands")
			map("ff", find_files_from_git_root, "Find file", true)
		end,
	},
}
