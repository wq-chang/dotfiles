--- Shared fixture utilities for the test suite.

local M = {}

--- Create a unique temporary directory.
---@return string
function M.tmpdir()
	local path = vim.fn.tempname()
	vim.fn.mkdir(path, "p")
	return path
end

--- Write a file, creating parent directories as needed.
---@param path string
---@param content string
function M.write_file(path, content)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	vim.fn.writefile(vim.split(content, "\n", { plain = true }), path)
end

--- Drop a module from the require cache so a rewritten fixture reloads.
---@param name string
function M.clear_require(name)
	package.loaded[name] = nil
end

return M
