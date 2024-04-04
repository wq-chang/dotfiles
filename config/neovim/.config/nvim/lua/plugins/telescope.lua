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
						},
					},
				},
				extensions = {
					live_grep_args = {
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

			local map = function(keys, func, desc)
				vim.keymap.set(
					"n",
					"<leader>" .. keys,
					"<cmd>" .. func .. "<cr>",
					{ desc = desc }
				)
			end
			map(
				"b",
				"Telescope buffers sort_mru=true sort_lastused=true",
				"Buffers"
			)
			map(
				"/",
				"lua require('telescope').extensions.live_grep_args.live_grep_args()",
				"Grep root dir"
			)
			map(".", "Telescope command_history", "Command history")
			map(
				"ff",
				"lua require('telescope.builtin').find_files()",
				"Find file"
			)
		end,
	},
}
