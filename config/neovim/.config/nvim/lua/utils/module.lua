local M = {}

function M.prequire(module)
	local status, lib = pcall(require, module)
	if status then
		return lib
	end
	return nil
end

return M
