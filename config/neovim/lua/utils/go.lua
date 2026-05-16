local file_utils = require("utils.file")

local M = {}

local integration_build_flag = "-tags=integration"

local function ensure_optimization_flag(flags)
	if flags == nil or flags == vim.NIL then
		return "-O2"
	end

	if flags == "" then
		return "-O2"
	end

	if flags:match("^%-O[%w]*") or flags:match("%s%-O[%w]*") then
		return flags
	end

	return vim.trim(flags .. " -O2")
end

function M.current_test_has_integration_build_tag()
	local buf = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buf)

	if vim.bo[buf].filetype ~= "go" or not path:match("_test%.go$") then
		return false
	end

	local max_lines = math.min(vim.api.nvim_buf_line_count(buf), 25)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, max_lines, false)

	for _, line in ipairs(lines) do
		if line:match("^package%s+") then
			break
		end

		if line:match("^//go:build") and not line:match("!integration") then
			return line:match("%f[%w]integration%f[%W]") ~= nil
		end

		if line:match("^// %+build") and not line:match("!integration") then
			return line:match("%f[%w]integration%f[%W]") ~= nil
		end
	end

	return false
end

function M.current_test_build_flags()
	if not M.current_test_has_integration_build_tag() then
		return {}
	end

	return { integration_build_flag }
end

function M.current_package_dir()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		return vim.fn.getcwd()
	end

	return vim.fn.fnamemodify(path, ":h")
end

function M.current_go_root()
	local root = file_utils.find_marker_in_parent({ "go.work", "go.mod" })
	if root ~= "" then
		return root
	end

	return M.current_package_dir()
end

function M.current_debug_env()
	return {
		CGO_CFLAGS = ensure_optimization_flag(os.getenv("CGO_CFLAGS")),
		CGO_CPPFLAGS = ensure_optimization_flag(os.getenv("CGO_CPPFLAGS")),
		CGO_CXXFLAGS = ensure_optimization_flag(os.getenv("CGO_CXXFLAGS")),
	}
end

function M.current_debug_test_config()
	return {
		buildFlags = M.current_test_build_flags(),
		cwd = M.current_go_root(),
		env = M.current_debug_env(),
		outputMode = "remote",
		program = M.current_package_dir(),
	}
end

return M
