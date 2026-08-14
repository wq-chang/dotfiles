local M = {}

---@param src string
---@param pattern string
---@return boolean
local function contains_string(src, pattern)
	if string.find(src, pattern) then
		return true
	end
	return false
end

--- Walk upward from the current buffer's directory looking for any of the
--- given markers; the first marker found (in argument order) wins. Returns ""
--- when nothing is found, when the buffer is a `jdt://` virtual buffer, or
--- when the walk reaches `$HOME`.
---@param markers string[]
---@return string
function M.find_marker_in_parent(markers)
	local excluded_patterns = { "jdt://" }
	local current_file = vim.fn.expand("%:p")
	for _, excluded_pattern in ipairs(excluded_patterns) do
		if contains_string(current_file, excluded_pattern) then
			return ""
		end
	end

	local home_dir = os.getenv("HOME")
	for _, marker in ipairs(markers) do
		local current_dir = vim.fn.fnamemodify(current_file, ":h")

		while
			current_dir ~= home_dir
			and current_dir ~= "/"
			and current_dir ~= ""
			and current_dir ~= "."
		do
			local marker_file = current_dir .. "/" .. marker
			if vim.loop.fs_stat(marker_file) then
				return current_dir
			end

			current_dir = vim.fn.fnamemodify(current_dir, ":h")
		end
	end

	return ""
end

return M
