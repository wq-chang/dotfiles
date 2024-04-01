local module_utils = require("utils/module")
local conform_mapper = require("customs/mason-mapper/conform_to_mason")
-- local nvim_lint_mapper = require("customs/mason-mapper/nvim_lint_to_mason")

local M = {}

local function map_to_mason_packages(packages, mapper)
	local r = {}
	for i, v in ipairs(packages) do
		r[i] = mapper[v]
		if not r[i] then
			error("Failed to map this package to mason package name: " .. v)
		end
	end

	return r
end

local get_ensure_installed_functions = {
	get_conform_ensured_installed = function()
		local conform = module_utils.try_require("conform")
		if not conform then
			return {}
		end

		local formatters_by_ft = conform.formatters_by_ft
		local formatter_list = vim.tbl_values(formatters_by_ft)
		local flatten_formatters = vim.tbl_flatten(formatter_list)
		return map_to_mason_packages(
			flatten_formatters,
			conform_mapper.conform_to_package
		)
	end,

	-- get_nvim_lint_ensure_installed = function()
	-- 	local conform = module_utils.try_require("conform")
	-- 	if not conform then
	-- 		return {}
	-- 	end
	--
	-- 	local formatters_by_ft = conform.formatters_by_ft
	-- 	local formatter_list = table_utils.get_table_values(formatters_by_ft)
	-- 	return table_utils.flat_map(formatter_list)
	-- end,
}

M.ensure_installed = {}

function M.add_all_ensure_installed(packages)
	vim.list_extend(M.ensure_installed, packages)
end

function M.get_ensure_installed()
	for _, v in pairs(get_ensure_installed_functions) do
		vim.list_extend(M.ensure_installed, v())
	end
	return M.ensure_installed
end

return M
