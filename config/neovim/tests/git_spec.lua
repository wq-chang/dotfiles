--- @diagnostic disable: undefined-global, undefined-field
-- busted globals (describe/it/assert.are) are provided by the test runner at runtime.

local helpers = dofile(vim.fn.stdpath("config") .. "/tests/helpers.lua")
local git_utils = require("utils.git")

describe("utils.git", function()
	---@type string
	local root
	---@type string
	local repo

	before_each(function()
		root = helpers.tmpdir()
		repo = root .. "/repo"
		vim.fn.mkdir(repo, "p")
		vim.fn.system("git -C " .. repo .. " init -q")
		assert.are.equal(0, vim.v.shell_error)
	end)

	it("lists ignored untracked files, stripping trailing slashes", function()
		helpers.write_file(repo .. "/.gitignore", "build/\n*.log")
		vim.fn.mkdir(repo .. "/build", "p")
		helpers.write_file(repo .. "/build/x.txt", "")
		helpers.write_file(repo .. "/a.log", "")
		helpers.write_file(repo .. "/tracked.txt", "")

		local result = vim.fn.sort(git_utils.get_git_ignored_files_in(repo))
		assert.are.same({ "a.log", "build" }, result)
	end)

	it("returns empty outside a git work tree", function()
		local plain = root .. "/plain"
		vim.fn.mkdir(plain, "p")
		assert.are.same({}, git_utils.get_git_ignored_files_in(plain))
	end)

	it("finds the repo root of the current buffer", function()
		vim.fn.mkdir(repo .. "/sub", "p")
		vim.cmd.edit(repo .. "/sub/file.txt")
		assert.are.equal(repo, git_utils.get_git_root())
	end)
end)
