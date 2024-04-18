local M = {}

function M.is_git_repo()
	vim.fn.system("git rev-parse --is-inside-work-tree")
	return vim.v.shell_error == 0
end

function M.get_git_root()
	local dot_git_path = vim.fn.finddir(".git", ".;")
	return vim.fn.fnamemodify(dot_git_path, ":h")
end

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
