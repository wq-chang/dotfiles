local file_utils = require("utils.file")

local M = {}

---@type string
M.integration_build_flag = "-tags=integration"

--- Append `-O2` to a Go toolchain flag string unless it already carries an
--- `-O` level (e.g. from `CGO_CFLAGS`), keeping the flags effective for
--- optimized debugging. Empty or nil input yields plain `-O2`.
---@param flags string|nil
---@return string
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

--- Whether the current Go test buffer has an integration build tag:
--- a `//go:build` or legacy `// +build` line mentioning `integration` (but
--- not negated with `!integration`) in the first 25 lines, before the
--- `package` clause.
---@return boolean
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

--- Build flags for the current test buffer: the integration tag only when
--- `current_test_has_integration_build_tag()` says so.
---@return string[]
function M.current_test_build_flags()
	if not M.current_test_has_integration_build_tag() then
		return {}
	end

	return { M.integration_build_flag }
end

--- Directory of the current buffer's file, or the working directory when
--- the buffer has no file name.
---@return string
function M.current_package_dir()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		return vim.fn.getcwd()
	end

	return vim.fn.fnamemodify(path, ":h")
end

--- Go module/work root of the current buffer (upward marker search), falling
--- back to `current_package_dir()`.
---@return string
function M.current_go_root()
	local root = file_utils.find_marker_in_parent({ "go.work", "go.mod" })
	if root ~= "" then
		return root
	end

	return M.current_package_dir()
end

--- Go toolchain env for debugging, with an `-O2` optimization level appended
--- to each CGO flags variable unless one is already set.
---@return { CGO_CFLAGS: string, CGO_CPPFLAGS: string, CGO_CXXFLAGS: string }
function M.current_debug_env()
	return {
		CGO_CFLAGS = ensure_optimization_flag(os.getenv("CGO_CFLAGS")),
		CGO_CPPFLAGS = ensure_optimization_flag(os.getenv("CGO_CPPFLAGS")),
		CGO_CXXFLAGS = ensure_optimization_flag(os.getenv("CGO_CXXFLAGS")),
	}
end

--- dap-go style test configuration for the current buffer.
---@return { buildFlags: string[], cwd: string, env: { CGO_CFLAGS: string, CGO_CPPFLAGS: string, CGO_CXXFLAGS: string }, outputMode: string, program: string }
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
