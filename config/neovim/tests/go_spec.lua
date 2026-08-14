--- @diagnostic disable: undefined-global, undefined-field
-- busted globals (describe/it/assert.are) are provided by the test runner at runtime.

local helpers = dofile(vim.fn.stdpath("config") .. "/tests/helpers.lua")
local go_utils = require("utils.go")

describe("utils.go", function()
	---@type string
	local root

	before_each(function()
		root = helpers.tmpdir()
		vim.cmd.edit(root .. "/foo_test.go")
		vim.bo[0].filetype = "go"
	end)

	after_each(function()
		vim.env.CGO_CFLAGS = nil
		vim.env.CGO_CPPFLAGS = nil
		vim.env.CGO_CXXFLAGS = nil
	end)

	---@param lines string[]
	local function set_lines(lines)
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	end

	it("detects //go:build integration tags", function()
		set_lines({ "//go:build integration", "", "package foo_tes" })
		assert.is_true(go_utils.current_test_has_integration_build_tag())
	end)

	it("detects integration inside compound build tags", function()
		set_lines({ "//go:build linux && integration", "package foo_test" })
		assert.is_true(go_utils.current_test_has_integration_build_tag())
	end)

	it("does not detect negated tags", function()
		set_lines({ "//go:build !integration", "package foo_test" })
		assert.is_false(go_utils.current_test_has_integration_build_tag())
	end)

	it("detects legacy // +build tags", function()
		set_lines({ "// +build integration", "package foo_test" })
		assert.is_true(go_utils.current_test_has_integration_build_tag())
	end)

	it("ignores tags after the package clause", function()
		set_lines({ "package foo_test", "//go:build integration" })
		assert.is_false(go_utils.current_test_has_integration_build_tag())
	end)

	it("ignores tags beyond the 25-line head", function()
		local lines = {}
		for i = 1, 26 do
			lines[i] = "// comment " .. i
		end
		lines[27] = "//go:build integration"
		set_lines(lines)
		assert.is_false(go_utils.current_test_has_integration_build_tag())
	end)

	it("requires a _test.go buffer", function()
		vim.cmd.edit(root .. "/main.go")
		vim.bo[0].filetype = "go"
		set_lines({ "//go:build integration", "package foo" })
		assert.is_false(go_utils.current_test_has_integration_build_tag())
	end)

	it("requires the go filetype", function()
		vim.bo[0].filetype = "lua"
		set_lines({ "//go:build integration", "package foo_test" })
		assert.is_false(go_utils.current_test_has_integration_build_tag())
	end)

	it("returns integration flags only when the tag is present", function()
		set_lines({ "//go:build integration", "package foo_test" })
		assert.are.same(
			{ "-tags=integration" },
			go_utils.current_test_build_flags()
		)

		set_lines({ "package foo_test" })
		assert.are.same({}, go_utils.current_test_build_flags())
	end)

	it("appends -O2 to debug env flags unless already set", function()
		vim.env.CGO_CFLAGS = "-g"
		vim.env.CGO_CPPFLAGS = "-O1"
		vim.env.CGO_CXXFLAGS = nil

		local env = go_utils.current_debug_env()
		assert.are.equal("-g -O2", env.CGO_CFLAGS)
		assert.are.equal("-O1", env.CGO_CPPFLAGS)
		assert.are.equal("-O2", env.CGO_CXXFLAGS)
	end)
end)
