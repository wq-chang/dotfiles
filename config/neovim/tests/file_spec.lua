--- @diagnostic disable: undefined-global, undefined-field
-- busted globals (describe/it/assert.are) are provided by the test runner at runtime.

local helpers = dofile(vim.fn.stdpath("config") .. "/tests/helpers.lua")
local file_utils = require("utils.file")

describe("utils.file", function()
	---@type string
	local root
	local orig_home = os.getenv("HOME")

	before_each(function()
		root = helpers.tmpdir()
		vim.cmd.edit(root .. "/project/src/main.go")
		vim.env.HOME = orig_home
	end)

	it("finds the nearest marker walking upward", function()
		helpers.write_file(root .. "/project/go.mod", "")
		assert.are.equal(
			root .. "/project",
			file_utils.find_marker_in_parent({ "go.mod" })
		)
	end)

	it("prefers the first marker in argument order", function()
		helpers.write_file(root .. "/project/go.work", "")
		helpers.write_file(root .. "/project/src/go.mod", "")
		assert.are.equal(
			root .. "/project",
			file_utils.find_marker_in_parent({ "go.work", "go.mod" })
		)
		assert.are.equal(
			root .. "/project/src",
			file_utils.find_marker_in_parent({ "go.mod", "go.work" })
		)
	end)

	it("stops at $HOME", function()
		vim.env.HOME = root .. "/project"
		helpers.write_file(root .. "/project/go.mod", "")
		assert.are.equal("", file_utils.find_marker_in_parent({ "go.mod" }))
	end)

	it("stops at the filesystem root", function()
		assert.are.equal("", file_utils.find_marker_in_parent({ "go.mod" }))
	end)

	it("returns empty for jdt:// buffers", function()
		vim.api.nvim_buf_set_name(0, "jdt://contents/Test.java")
		assert.are.equal("", file_utils.find_marker_in_parent({ "go.mod" }))
	end)

	it("returns empty when no marker exists", function()
		assert.are.equal(
			"",
			file_utils.find_marker_in_parent({ "go.work", "go.mod" })
		)
	end)
end)
