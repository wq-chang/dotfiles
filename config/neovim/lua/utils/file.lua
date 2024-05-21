local M = {}

function M.find_marker_in_parent(markers)
	for _, marker in ipairs(markers) do
		local home_dir = os.getenv("HOME")
		local current_file = vim.fn.expand("%:p")
		local current_dir = vim.fn.fnamemodify(current_file, ":h")

		while current_dir ~= home_dir and current_dir ~= "" do
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
