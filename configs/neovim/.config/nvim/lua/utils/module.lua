local M = {}

function M.try_require(module)
	local status, lib = pcall(require, module)
	if status then
		return lib
	end
	return nil
end

return M
