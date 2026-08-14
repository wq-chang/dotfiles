-- Helpers live at module level with lazy `require("oil")` calls: pack.lua
-- loads spec files before plugins are on the runtimepath, so requiring a
-- plugin at the top of a spec file would fail (and cost startup time).

local git_utils = require("utils.git")

-- Per-directory cache of git-ignored entries. Computing the list spawns
-- a git subprocess, and `is_hidden_file` runs once per entry per render,
-- so the lookup must not hit the subprocess per entry. The cache is
-- reset when the shown directory changes (dir-keyed) or when the user
-- triggers a refresh (<C-r>), so .gitignore edits are picked up.
local cached_dir = nil
local cached_ignored = {}

---@param name string
---@return boolean
local function is_git_ignored(name)
	local oil = require("oil")
	-- Non-oil buffer (or an oil buffer with an unparseable name): only
	-- the parent entry is hidden.
	local ok, current_dir = pcall(oil.get_current_dir)
	if not ok or not current_dir then
		return name == ".."
	end
	if current_dir ~= cached_dir then
		cached_dir = current_dir
		cached_ignored = { [".."] = true }
		for _, ignored in
			ipairs(git_utils.get_git_ignored_files_in(current_dir))
		do
			cached_ignored[ignored] = true
		end
	end
	return cached_ignored[name] == true
end

local function refresh_with_cache_reset()
	cached_dir = nil -- force recomputation on the next render
	require("oil.actions").refresh.callback()
end

local function select_or_preview()
	local oil = require("oil")
	local entry = oil.get_cursor_entry()
	if entry and entry.type == "file" then
		oil.open_preview()
		return
	end
	oil.select()
end

local function discard_all_changes()
	require("oil").discard_all_changes()
end

local function open_from_root()
	local oil = require("oil")
	oil.open(git_utils.get_git_root())
end

return {
	src = "stevearc/oil.nvim",
	opts = {
		default_file_explorer = true,
		keymaps = {
			["g?"] = "actions.show_help",
			["l"] = select_or_preview,
			["<CR>"] = "actions.select",
			["<C-v>"] = "actions.select_vsplit",
			["<C-s>"] = "actions.select_split",
			["<C-p>"] = "actions.preview",
			q = "actions.close",
			["<C-r>"] = {
				callback = refresh_with_cache_reset,
				desc = "Refresh current directory list",
			},
			["h"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = "actions.tcd",
			["gs"] = "actions.change_sort",
			["gx"] = "actions.open_external",
			["g."] = "actions.toggle_hidden",
			["g\\"] = "actions.toggle_trash",
			["<BS>"] = discard_all_changes,
		},
		use_default_keymaps = false,
		view_options = {
			is_hidden_file = is_git_ignored,
		},
		win_options = {
			winbar = "%{v:lua.require('oil').get_current_dir()}",
		},
	},
	config = function(opts)
		require("oil").setup(opts)
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
}
