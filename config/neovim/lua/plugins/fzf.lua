return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		defaults = {
			git_icons = true,
		},
		hls = {
			border = "FloatBorder",
			preview_border = "FloatBorder",
			scrollborder_f = "Whitespace",
		},
		grep = {
			hidden = true,
		},
		lsp = {
			code_actions = {
				previewer = "codeaction_native",
				preview_pager = "delta -s --width=$COLUMNS --hunk-header-style='omit' --file-style='omit'",
			},
			jump1 = true,
		},
		winopts = {
			preview = {
				default = "builtin",
				vertical = "up:65%",
				layout = "vertical",
			},
		},
		keymap = {
			builtin = {
				["<C-u>"] = "preview-page-up",
				["<C-d>"] = "preview-page-down",
			},
		},
	},
	config = function(_, opts)
		local fzf = require("fzf-lua")
		fzf.setup(opts)
		local git_utils = require("utils.git")
		local function find_files_from_git_root()
			local cwd = git_utils.get_git_root()
			fzf.files({ cwd = cwd })
		end
		local function live_grep_from_git_root(is_resume)
			local cwd = git_utils.get_git_root()
			if is_resume then
				fzf.live_grep_resume({ cwd = cwd })
			else
				fzf.live_grep({ cwd = cwd })
			end
		end
		local function map(keys, func, desc)
			vim.keymap.set("n", keys, func, { desc = desc })
		end

		-- stylua: ignore start
		map("<leader>b", "<cmd>FzfLua buffers<cr>", "Buffers")
		map("<leader>/", function() live_grep_from_git_root() end, "Grep root dir")
		map("<leader>?", function() live_grep_from_git_root(true) end, "Grep root dir")
		map("<leader>.", "<cmd>FzfLua command_history<cr>", "Command history")
		map("<leader>fc", "<cmd>FzfLua commands<cr>", "Find commands")
		map("<leader>ff", find_files_from_git_root, "Find file")
		-- stylua: ignore end
	end,
}
