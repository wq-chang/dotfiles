local M = {}

local function contains_string(src, pattern)
	if string.find(src, pattern) then
		return true
	end
	return false
end

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
