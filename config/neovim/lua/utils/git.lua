local M = {}

--- Whether the current working directory is inside a git work tree.
---@return boolean
function M.is_git_repo()
	vim.fn.system("git rev-parse --is-inside-work-tree")
	return vim.v.shell_error == 0
end

--- Root of the git repository containing the current buffer's file
--- (searches upward from the file's directory).
---@return string
function M.get_git_root()
	local current_dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
	local found = vim.fs.find(".git", { upward = true, path = current_dir })
	if #found == 0 then
		return ""
	end
	return vim.fn.fnamemodify(found[1], ":h")
end

--- List of ignored, untracked files under `dir` (via `git ls-files
--- --ignored`); trailing slashes are stripped so directories are reported
--- without them. Returns {} when `dir` is not inside a git work tree.
---@param dir string
---@return string[]
function M.get_git_ignored_files_in(dir)
	local found = vim.fs.find(".git", {
		upward = true,
		path = dir,
	})
	if #found == 0 then
		return {}
	end

	local cmd = string.format(
		"git -C %s ls-files --ignored --exclude-standard --others --directory 2>/dev/null",
		dir
	)

	local handle = io.popen(cmd)
	if handle == nil then
		return {}
	end

	local ignored_files = {}
	for line in handle:lines("*l") do
		line = line:gsub("/$", "")
		table.insert(ignored_files, line)
	end
	handle:close()

	return ignored_files
end

return M
