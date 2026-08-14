--- @diagnostic disable: undefined-global, undefined-field, duplicate-set-field
-- busted globals (describe/it/assert.are) are provided by the test runner at runtime;
-- vim.notify, vim.pack.update and vim.pack.del are temporarily reassigned by
-- individual tests and restored in after_each.

local helpers = dofile(vim.fn.stdpath("config") .. "/tests/helpers.lua")
local pack = require("pack")

-- Snapshot rtp once; before_each restores it so fixtures don't leak across tests.
local base_rtp = vim.o.runtimepath

describe("pack", function()
	---@type string
	local specs_dir
	---@type string
	local pack_base
	---@type string|nil
	local root_dir
	---@type table
	local log
	---@type vim.pack.Spec[]
	local pack_add_calls
	local base_packpath = vim.o.packpath
	local base_notify = vim.notify
	local orig_pack_update = vim.pack.update
	local orig_pack_del = vim.pack.del

	local function fake_pack_add(specs)
		vim.list_extend(pack_add_calls, specs)
	end

	---@param name string
	---@param body string
	local function write_spec(name, body)
		helpers.write_file(specs_dir .. "/" .. name .. ".lua", body)
		-- Module prefix must mirror pack.collect_specs' derivation from the dir.
		helpers.clear_require(
			vim.fn.fnamemodify(specs_dir, ":t") .. "." .. name
		)
	end

	--- Create a fixture plugin whose setup() records { name, opts } into
	--- _G.pack_test_log, and expose it on the runtimepath.
	---@param plugin_name string
	---@param module_name string
	local function make_plugin(plugin_name, module_name)
		helpers.write_file(
			pack_base
				.. "/pack/core/opt/"
				.. plugin_name
				.. "/lua/"
				.. module_name
				.. "/init.lua",
			(
				"local M = {}\n"
				.. "function M.setup(opts)\n"
				.. "  _G.pack_test_log[#_G.pack_test_log + 1] = { name = %q, opts = opts }\n"
				.. "end\n"
				.. "return M\n"
			):format(plugin_name)
		)
		vim.opt.runtimepath:prepend(
			pack_base .. "/pack/core/opt/" .. plugin_name
		)
		helpers.clear_require(module_name)
	end

	before_each(function()
		root_dir = helpers.tmpdir()
		specs_dir = root_dir .. "/specs/lua/plugins"
		pack_base = root_dir .. "/packdata/site"
		vim.fn.mkdir(specs_dir, "p")
		vim.fn.mkdir(pack_base, "p")

		-- Isolate the loader: fixtures only on packpath, fixtures + defaults on rtp.
		vim.o.packpath = pack_base
		vim.o.runtimepath = base_rtp
		vim.opt.runtimepath:prepend(root_dir .. "/specs")

		log = {}
		_G.pack_test_log = log
		vim.g.pack_init_ran = nil
		_G.pack_build_ran = nil
		pack_add_calls = {}
	end)

	after_each(function()
		vim.o.packpath = base_packpath
		vim.notify = base_notify
		vim.pack.update = orig_pack_update
		vim.pack.del = orig_pack_del
		vim.g.pack_init_ran = nil
		vim.api.nvim_create_augroup("pack_build_hooks", { clear = true })
		if root_dir then
			vim.fn.delete(root_dir, "rf")
			root_dir = nil
		end
		_G.pack_test_log = nil
		_G.pack_build_ran = nil
		_G.pack_build_args = nil
	end)

	it(
		"configures plugins in dependency order with resolved modules and opts",
		function()
			write_spec(
				"luasnip",
				[[return { { src = "L3MON4D3/LuaSnip", opts = { history = true } } }]]
			)
			write_spec(
				"bqf",
				[[return { { src = "kevinhwang91/nvim-bqf", after = "LuaSnip", opts = { preview = { winblend = 0 } } } }]]
			)
			write_spec(
				"disabled",
				[[return { { src = "acme/disabled-plugin", enabled = false, opts = {} } }]]
			)
			write_spec(
				"priority",
				[[return { { src = "acme/priority-high", priority = 100, opts = {} } }]]
			)

			make_plugin("LuaSnip", "luasnip")
			make_plugin("nvim-bqf", "bqf")
			make_plugin("priority-high", "priority_high")

			pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

			-- Highest priority first, then LuaSnip, then nvim-bqf (after LuaSnip).
			-- The disabled plugin must appear neither in the setup log nor in the
			-- specs handed to pack_add.
			assert.are.same(
				{ "priority-high", "LuaSnip", "nvim-bqf" },
				vim.tbl_map(function(entry)
					return entry.name
				end, log)
			)
			assert.are.same(
				{ "priority-high", "LuaSnip", "nvim-bqf" },
				vim.tbl_map(function(spec)
					return spec.name
				end, pack_add_calls)
			)
			-- opts are delivered verbatim to the resolved module's setup().
			assert.are.same({ history = true }, log[2].opts)
			assert.are.equal(0, log[3].opts.preview.winblend)
		end
	)

	it("passes normalized specs to pack_add", function()
		write_spec(
			"vers",
			[[return { { src = "acme/versioned", version = ">=0.0.0", init = function() vim.g.pack_init_ran = true end, opts = {} } }]]
		)
		make_plugin("versioned", "versioned")

		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		assert.is_true(vim.g.pack_init_ran)
		assert.are.equal(1, #pack_add_calls)
		assert.are.equal(
			"https://github.com/acme/versioned",
			pack_add_calls[1].src
		)
		assert.are.equal("versioned", pack_add_calls[1].name)
		assert.are.equal(">=0.0.0", pack_add_calls[1].version)
	end)

	it("supports opts functions and config overrides", function()
		write_spec(
			"fnopts",
			[[return { { src = "acme/fn-opts", opts = function() return { a = 1 } end } }]]
		)
		write_spec(
			"custom",
			[[return {
				{
					src = "acme/custom",
					priority = 100,
					opts = { b = 2 },
					config = function(opts)
						_G.pack_test_log[#_G.pack_test_log + 1] = { name = "custom-config", opts = opts }
					end,
				},
			}]]
		)
		make_plugin("fn-opts", "fn_opts")
		-- The custom-config plugin has a fixture too, so if configure() also ran
		-- the auto-setup path, its entry would appear in the log and fail this.
		make_plugin("custom", "custom")

		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		assert.are.same(
			{ "custom-config", "fn-opts" },
			vim.tbl_map(function(entry)
				return entry.name
			end, log)
		)
		assert.are.same({ b = 2 }, log[1].opts)
		assert.are.same({ a = 1 }, log[2].opts)
	end)

	it("errors on circular dependencies", function()
		write_spec(
			"a",
			[[return { { src = "acme/a", after = "b", opts = {} } }]]
		)
		write_spec(
			"b",
			[[return { { src = "acme/b", after = "a", opts = {} } }]]
		)

		local ok, err = pcall(
			pack.setup,
			{ plugins_dir = specs_dir, pack_add = fake_pack_add }
		)
		assert.is_false(ok)
		assert.matches("circular dependency", err)
	end)

	it("fires build hooks on PackChanged install/update", function()
		write_spec(
			"buildy",
			[[return { { src = "acme/buildy", build = function(a) _G.pack_build_args = a; _G.pack_build_ran = true end, opts = {} } }]]
		)
		make_plugin("buildy", "buildy")

		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		_G.pack_build_ran = false
		-- vim.pack fires the PackChanged event directly (not User + pattern);
		-- only install/update kinds trigger the hook. `active` is true here
		-- because the runtime path is under test (vim_did_init == 1 in tests).
		vim.api.nvim_exec_autocmds("PackChanged", {
			pattern = "/tmp/fake-plugin-path",
			data = {
				spec = { name = "buildy" },
				kind = "install",
				path = "/tmp/fake-plugin-path",
				active = true,
			},
		})
		assert.is_true(_G.pack_build_ran)
		assert.are.same({
			name = "buildy",
			path = "/tmp/fake-plugin-path",
			kind = "install",
		}, _G.pack_build_args)

		_G.pack_build_ran = false
		vim.api.nvim_exec_autocmds("PackChanged", {
			pattern = "/tmp/fake-plugin-path",
			data = {
				spec = { name = "buildy" },
				kind = "delete",
				path = "/tmp/fake-plugin-path",
				active = true,
			},
		})
		assert.is_false(_G.pack_build_ran)

		-- Startup installs are deferred to VimEnter; the deferral autocmd
		-- must exist after setup (the vim_did_init == 0 window can't be faked).
		assert.is_true(#vim.api.nvim_get_autocmds({
			group = "pack_build_hooks",
			event = "VimEnter",
		}) > 0)
	end)

	it("defers startup install hooks until VimEnter", function()
		write_spec(
			"buildy",
			[[return { { src = "acme/buildy", build = function(a) _G.pack_build_args = a; _G.pack_build_ran = true end, opts = {} } }]]
		)
		make_plugin("buildy", "buildy")

		-- is_startup seam: simulate the init.lua window (vim_did_init == 0).
		pack.setup({
			plugins_dir = specs_dir,
			pack_add = fake_pack_add,
			is_startup = function()
				return true
			end,
		})

		_G.pack_build_ran = false
		vim.api.nvim_exec_autocmds("PackChanged", {
			pattern = "/tmp/fake-plugin-path",
			data = {
				spec = { name = "buildy" },
				kind = "install",
				path = "/tmp/fake-plugin-path",
				active = false,
			},
		})
		assert.is_false(
			_G.pack_build_ran,
			"hook must be deferred during startup"
		)

		vim.api.nvim_exec_autocmds("VimEnter", {})
		assert.is_true(_G.pack_build_ran, "deferred hook must run at VimEnter")
		assert.are.same({
			name = "buildy",
			path = "/tmp/fake-plugin-path",
			kind = "install",
		}, _G.pack_build_args)
	end)

	it("orders equal-priority plugins deterministically by name", function()
		-- Glob order conflicts with name order: a_tie.lua globs first but holds
		-- "zz-tie", so only the name tiebreak yields { aa-tie, zz-tie }.
		write_spec("z_tie", [[return { { src = "acme/aa-tie", opts = {} } }]])
		write_spec("a_tie", [[return { { src = "acme/zz-tie", opts = {} } }]])
		make_plugin("aa-tie", "aa_tie")
		make_plugin("zz-tie", "zz_tie")

		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		assert.are.same(
			{ "aa-tie", "zz-tie" },
			vim.tbl_map(function(entry)
				return entry.name
			end, log)
		)
	end)

	it("honors the spec.module override", function()
		write_spec(
			"modx",
			[[return { { src = "acme/modx", module = "target_mod", opts = {} } }]]
		)
		-- Two top-level modules make the directory scan ambiguous; only the
		-- explicit `module` field can pick the right one.
		make_plugin("modx", "target_mod")
		helpers.write_file(
			pack_base .. "/pack/core/opt/modx/lua/other_mod/init.lua",
			"return { setup = function() end }\n"
		)

		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		assert.are.same(
			{ "modx" },
			vim.tbl_map(function(entry)
				return entry.name
			end, log)
		)
	end)

	it(
		"picks the lua dir candidate matching the plugin name when ambiguous",
		function()
			write_spec(
				"bqf",
				[[return { { src = "kevinhwang91/nvim-bqf", opts = {} } }]]
			)
			make_plugin("nvim-bqf", "nvim_bqf")
			-- A second top-level module makes the directory scan ambiguous; only
			-- the normalized-name match can pick the right one.
			helpers.write_file(
				pack_base .. "/pack/core/opt/nvim-bqf/lua/zz_other/init.lua",
				"return { setup = function() end }\n"
			)

			pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

			-- zz_other has a setup() too, so if resolve_module picked it (or fell
			-- back to the derived name), the log would differ.
			assert.are.same(
				{ "nvim-bqf" },
				vim.tbl_map(function(entry)
					return entry.name
				end, log)
			)
		end
	)

	it(
		"falls back to the derived module when the lua dir scan is ambiguous",
		function()
			write_spec(
				"bqf",
				[[return { { src = "kevinhwang91/nvim-bqf", opts = {} } }]]
			)
			make_plugin("nvim-bqf", "alpha_mod")
			helpers.write_file(
				pack_base .. "/pack/core/opt/nvim-bqf/lua/beta_mod/init.lua",
				"return { setup = function() end }\n"
			)

			local notified = {}
			local orig_notify = vim.notify
			vim.notify = function(msg, lvl)
				notified[#notified + 1] = { msg = tostring(msg), lvl = lvl }
			end
			pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })
			vim.notify = orig_notify

			-- Neither candidate matches; the derived module "nvim-bqf" is not on
			-- the runtimepath, so the require fails with a single warning.
			assert.are.equal(1, #notified)
			assert.matches("failed to require", notified[1].msg)
			assert.are.same({}, log)
		end
	)

	it("warns about after dependencies on unknown plugins", function()
		write_spec(
			"orphan",
			[[return { { src = "acme/orphan", after = "ghost", opts = {} } }]]
		)
		make_plugin("orphan", "orphan")

		local notified = {}
		local orig_notify = vim.notify
		vim.notify = function(msg, lvl)
			notified[#notified + 1] = { msg = tostring(msg), lvl = lvl }
		end
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })
		vim.notify = orig_notify

		assert.are.equal(1, #notified)
		assert.matches("depends on unknown plugin", notified[1].msg)
		assert.matches("ghost", notified[1].msg)
	end)

	it("errors on duplicate spec names", function()
		write_spec(
			"dup1",
			[[return { { src = "acme/a", name = "same", opts = {} } }]]
		)
		write_spec(
			"dup2",
			[[return { { src = "acme/b", name = "same", opts = {} } }]]
		)

		local ok, err = pcall(pack.setup, {
			plugins_dir = specs_dir,
			pack_add = fake_pack_add,
		})
		assert.is_false(ok)
		assert.matches("duplicate spec name", err)
	end)

	it("warns and ignores specs without a src", function()
		write_spec("nosrc", [[return { { name = "acme/no-src" } }]])

		local notified = {}
		local orig_notify = vim.notify
		vim.notify = function(msg, lvl)
			notified[#notified + 1] = { msg = tostring(msg), lvl = lvl }
		end
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })
		vim.notify = orig_notify

		-- The malformed spec warn plus the "no specs found" warn both fire.
		local msgs = table.concat(
			vim.tbl_map(function(n)
				return n.msg
			end, notified),
			"\n"
		)
		assert.matches("missing 'src'", msgs)
		assert.are.same({}, pack_add_calls)
	end)

	it("warns when a spec file returns a non-table", function()
		write_spec("bogus", [[return true]])

		local notified = {}
		local orig_notify = vim.notify
		vim.notify = function(msg, lvl)
			notified[#notified + 1] = { msg = tostring(msg), lvl = lvl }
		end
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })
		vim.notify = orig_notify

		local msgs = table.concat(
			vim.tbl_map(function(n)
				return n.msg
			end, notified),
			"\n"
		)
		assert.matches("returned a non%-table", msgs)
		assert.matches("bogus", msgs)
	end)

	it("loads specs from a directory named other than 'plugins'", function()
		specs_dir = root_dir .. "/specs/lua/custom"
		vim.fn.mkdir(specs_dir, "p")
		write_spec(
			"customp",
			[[return { { src = "acme/customp", opts = {} } }]]
		)
		make_plugin("customp", "customp")

		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		-- Only the prefix derivation (custom -> custom.<name>) makes the
		-- require work; a hardcoded "plugins." prefix would fail this test.
		assert.are.same(
			{ "customp" },
			vim.tbl_map(function(entry)
				return entry.name
			end, log)
		)
	end)

	it(
		"warns on non-table list entries but still loads valid siblings",
		function()
			write_spec(
				"mixed",
				[[return { { src = "acme/good", opts = {} }, true }]]
			)
			make_plugin("good", "good")

			local notified = {}
			local orig_notify = vim.notify
			vim.notify = function(msg, lvl)
				notified[#notified + 1] = { msg = tostring(msg), lvl = lvl }
			end
			pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })
			vim.notify = orig_notify

			assert.are.equal(1, #notified)
			assert.matches("missing 'src'", notified[1].msg)
			assert.are.same(
				{ "good" },
				vim.tbl_map(function(entry)
					return entry.name
				end, log)
			)
		end
	)

	it("warns when a spec file returns an empty table", function()
		write_spec("empty", [[return {}]])

		local notified = {}
		local orig_notify = vim.notify
		vim.notify = function(msg, lvl)
			notified[#notified + 1] = { msg = tostring(msg), lvl = lvl }
		end
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })
		vim.notify = orig_notify

		local msgs = table.concat(
			vim.tbl_map(function(n)
				return n.msg
			end, notified),
			"\n"
		)
		assert.matches("no usable specs", msgs)
	end)

	it("registers the PackUpdate command", function()
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		assert.are.equal(2, vim.fn.exists(":PackUpdate"))
	end)

	it("maps PackUpdate bang and names to vim.pack.update", function()
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		local calls = {}
		vim.pack.update = function(names, opts)
			calls[#calls + 1] = { names = names, opts = opts }
		end

		vim.cmd("PackUpdate! LuaSnip blink.cmp")
		assert.are.same({ "LuaSnip", "blink.cmp" }, calls[1].names)
		assert.is_true(calls[1].opts.force)

		vim.cmd("PackUpdate")
		assert.are.same(nil, calls[2].names)
		assert.is_false(calls[2].opts.force)
	end)

	it("registers the PackDelete command", function()
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		assert.are.equal(2, vim.fn.exists(":PackDelete"))
	end)

	it("maps PackDelete bang and names to vim.pack.del", function()
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		local calls = {}
		vim.pack.del = function(names, opts)
			calls[#calls + 1] = { names = names, opts = opts }
		end

		vim.cmd("PackDelete! LuaSnip blink.cmp")
		assert.are.same({ "LuaSnip", "blink.cmp" }, calls[1].names)
		assert.is_true(calls[1].opts.force)

		vim.cmd("PackDelete")
		assert.are.same(1, #calls) -- no names: warn, don't call vim.pack.del
	end)

	it("warns instead of calling vim.pack.del without names", function()
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })

		local notified = {}
		local orig_notify = vim.notify
		vim.notify = function(msg, lvl)
			notified[#notified + 1] = { msg = tostring(msg), lvl = lvl }
		end
		local del_called = false
		vim.pack.del = function()
			del_called = true
		end

		vim.cmd("PackDelete")
		assert.is_false(del_called)
		assert.are.same(vim.log.levels.WARN, notified[1].lvl)
		assert.matches("no plugin names", notified[1].msg)

		vim.notify = orig_notify
	end)

	it("warns when an opts function returns nil", function()
		write_spec(
			"nilopts",
			[[return { { src = "acme/nilopts", opts = function() return nil end } }]]
		)
		make_plugin("nilopts", "nilopts")

		local notified = {}
		local orig_notify = vim.notify
		vim.notify = function(msg, lvl)
			notified[#notified + 1] = { msg = tostring(msg), lvl = lvl }
		end
		pack.setup({ plugins_dir = specs_dir, pack_add = fake_pack_add })
		vim.notify = orig_notify

		assert.are.equal(1, #notified)
		assert.matches("returned nil", notified[1].msg)
		-- setup() was skipped, so nothing was logged.
		assert.are.same({}, log)
	end)
end)
