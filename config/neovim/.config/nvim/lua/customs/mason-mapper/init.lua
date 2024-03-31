local module_utils = require("utils/module")
local table_utils = require("utils/table")
local conform_mapper = require("customs/mason-mapper/conform_to_mason")
local nvim_lint_mapper = require("customs/mason-mapper/nvim_lint_to_mason")

local M = {}

local supported_modules = {
	conform = conform_mapper.conform_to_package,
	lsp = {},
	nvim_lint = nvim_lint_mapper.nvimlint_to_package,
}

function M.get_wanted_packages(plugin_name)
	local plugin = module_utils.prequire("plugins/" .. plugin_name)
	if plugin then
		return plugin[1].get_wanted_packages()
	end
	return {}
end

function M.get_all_wanted_packages()
	local r = {}
	for k, v in pairs(supported_modules) do
		local wanted_packages = M.get_wanted_packages(k)
		local mapped_packages = {}
		local has_mapper = next(v) ~= nil
		for nk, nv in pairs(wanted_packages) do
			if has_mapper then
				mapped_packages[nk] = v[nv]
			else
				mapped_packages[nk] = nv
			end
		end
		r = table_utils.concat_arrays(r, mapped_packages)
	end
	return r
end

return M
