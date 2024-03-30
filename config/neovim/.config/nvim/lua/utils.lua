local M = {}

-- Key Binding Utils
function M.map(mode, lhs, rhs, opts)
	vim.keymap.set(mode, lhs, rhs, opts)
end

return M
