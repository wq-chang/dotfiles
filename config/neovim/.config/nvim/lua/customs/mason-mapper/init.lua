local module_utils = require("utils.module")
local mappings = require("customs.mason-mapper.mapping")

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

local function get_ensure_installed_function(
	module_name,
	packages_mapper,
	mapping
)
	local module = module_utils.try_require(module_name)
	if not module then
		return {}
	end
	local packages_by_ft = packages_mapper(module)
	local packages = vim.tbl_values(packages_by_ft)
	local flatten_packages = vim.tbl_flatten(packages)
	flatten_packages = vim.tbl_flatten(flatten_packages)
	return map_to_mason_packages(flatten_packages, mapping)
end

local get_ensure_installed_functions = {
	get_conform_ensured_installed = function()
		local function get_conform_packages(conform)
			return conform.formatters_by_ft
		end

		return get_ensure_installed_function(
			"conform",
			get_conform_packages,
			mappings.conform_to_mason
		)
	end,

	get_nvim_lint_ensure_installed = function()
		local function get_conform_packages(lint)
			return lint.linters_by_ft
		end

		return get_ensure_installed_function(
			"lint",
			get_conform_packages,
			mappings.nvimlint_to_mason
		)
	end,
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
