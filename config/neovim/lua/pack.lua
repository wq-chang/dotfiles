--- Minimal plugin loader on top of `vim.pack`, driven by spec files in
--- `lua/plugins/*.lua`

---@class pack.Spec
---@field src string Plugin source (repo path or URL).
---@field name string Plugin name (directory name).
---@field after string[] Plugins that must be configured first (normalized; raw specs may use a single string).
---@field priority integer Sort priority (higher = earlier) among plugins without `after` deps.
---@field enabled? boolean|fun(): boolean Whether the plugin is active.
---@field opts? table|fun(): table|nil Options passed to the plugin's `setup()`.
---@field config? fun(opts: table) Custom config function (replaces auto `setup`).
---@field init? fun() Hook run before plugins are installed/loaded.
---@field build? string|fun(args: {name: string, path: string, kind: string}) Hook run on install/update (`:`-prefixed strings run as Ex commands).
---@field module? string Module to `require` for setup (default: derived from the name).
---@field version? string|vim.VersionRange Version constraint passed through to `vim.pack`.

---@class pack.SetupOpts
---@field plugins_dir string Directory containing `*.lua` spec files.
---@field is_startup? fun(): boolean Test seam: whether nvim is still initializing (default: `vim_did_init == 0`).
---@field pack_add fun(specs: vim.pack.Spec[]) Installer for resolved specs (defaults to `vim.pack.add`).

local M = {}

---@param src string
---@return string
local function derive_name(src)
	return src:match("[^/]+$")
end

---@param name string
---@return string
local function derive_module(name)
	return (name:gsub("%.nvim$", ""):gsub("%.lua$", ""))
end

---@param name string
---@return string|nil
local function plugin_path(name)
	return vim.fn.globpath(vim.o.packpath, "pack/*/opt/" .. name, false, true)[1]
end

---@param module string
---@return boolean
local function module_on_rtp(module)
	for _, pat in ipairs({
		"lua/" .. module .. "/init.lua",
		"lua/" .. module .. ".lua",
	}) do
		if vim.fn.globpath(vim.o.runtimepath, pat, false, true)[1] then
			return true
		end
	end
	return false
end

---@param s string
---@return string
local function norm(s)
	return (s:lower():gsub("[^%w]", ""))
end

--- Resolve the module to configure for a plugin:
---   1. explicit `spec.module` wins;
---   2. the name-derived module, if it exists on the runtimepath;
---   3. the plugin's own `lua/` directory (e.g. nvim-bqf -> bqf, LuaSnip -> luasnip).
---@param spec pack.Spec
---@return string
local function resolve_module(spec)
	if spec.module then
		return spec.module
	end

	local derived = derive_module(spec.name)
	if module_on_rtp(derived) then
		return derived
	end

	local path = plugin_path(spec.name)
	local lua_dir = path and (path .. "/lua") or nil
	if lua_dir and vim.fn.isdirectory(lua_dir) == 1 then
		local candidates, seen = {}, {}
		local target = norm(spec.name)
		for _, entry in ipairs(vim.fn.readdir(lua_dir)) do
			local mod = entry:gsub("%.lua$", "")
			local is_file = entry:match("%.lua$") ~= nil
			local is_init_dir = vim.fn.isdirectory(lua_dir .. "/" .. entry) == 1
				and vim.fn.filereadable(
						lua_dir .. "/" .. entry .. "/init.lua"
					)
					== 1
			if (is_file or is_init_dir) and not seen[mod] then
				seen[mod] = true
				table.insert(candidates, mod)
			end
		end
		-- Directory order is not guaranteed; sort so the normalized-name match
		-- (and the first match on ties) is deterministic.
		table.sort(candidates)
		-- Prefer a candidate whose normalized name matches the plugin name,
		-- otherwise use the single candidate if unambiguous.
		for _, c in ipairs(candidates) do
			if norm(c) == target then
				return c
			end
		end
		if #candidates == 1 then
			return candidates[1]
		end
	end

	return derived
end

---@param src string
---@return string
local function expand_url(src)
	if src:match("^https?://") then
		return src
	end
	return "https://github.com/" .. src
end

--- Fill in defaults (`name`, `after`, `priority`), mutating and returning `spec`.
---@param spec pack.Spec
---@return pack.Spec
local function normalize_spec(spec)
	spec.name = spec.name or derive_name(spec.src)
	---@type string|string[]
	local after = spec.after
	if after == nil then
		spec.after = {}
	elseif type(after) == "string" then
		spec.after = { after }
	end
	spec.priority = spec.priority or 50
	return spec
end

---@param spec pack.Spec
---@return boolean
local function is_enabled(spec)
	local enabled = spec.enabled
	if enabled == nil then
		return true
	end
	if type(enabled) == "function" then
		return enabled()
	end
	return enabled
end

--- Load and normalize all spec files from `plugins_dir`.
--- Spec files must be require-able as `<dir-name>.<name>`, where `<dir-name>`
--- is the basename of `plugins_dir` (e.g. `lua/plugins/` -> `plugins.<name>`).
---@param plugins_dir string
---@return pack.Spec[]
local function collect_specs(plugins_dir)
	local specs = {}
	local files = vim.fn.glob(plugins_dir .. "/*.lua", false, true)
	local prefix = vim.fn.fnamemodify(plugins_dir, ":t")

	for _, file in ipairs(files) do
		local module_name = prefix .. "." .. vim.fn.fnamemodify(file, ":t:r")
		local ok, result = pcall(require, module_name)
		if not ok then
			vim.notify(
				"pack: failed to load "
					.. module_name
					.. ": "
					.. tostring(result),
				vim.log.levels.WARN
			)
		elseif type(result) ~= "table" then
			-- A spec file returning a non-table (e.g. `return true`) would crash
			-- on `result.src` below, so warn instead.
			vim.notify(
				"pack: spec module "
					.. module_name
					.. " returned a non-table value ("
					.. type(result)
					.. ") and was ignored",
				vim.log.levels.WARN
			)
		elseif result.src then
			table.insert(specs, normalize_spec(result))
		else
			local count = 0
			for _, spec in ipairs(result) do
				if type(spec) == "table" and spec.src then
					count = count + 1
					table.insert(specs, normalize_spec(spec))
				else
					vim.notify(
						"pack: spec in "
							.. module_name
							.. " is missing 'src' and was ignored",
						vim.log.levels.WARN
					)
				end
			end
			if count == 0 and #result == 0 then
				-- Dict-form or empty tables would otherwise be silently dropped,
				-- leaving only the misleading "no specs found" setup warning.
				vim.notify(
					"pack: spec module "
						.. module_name
						.. " returned no usable specs (expected a spec or a list of specs)",
					vim.log.levels.WARN
				)
			end
		end
	end

	return specs
end

--- Order specs so that every `after` dependency comes first; ties broken by
--- `priority` (higher first), then by name for determinism. Raises an error
--- naming the leftover specs when the dependency graph has a cycle.
---@param specs pack.Spec[]
---@return pack.Spec[]
local function topo_sort(specs)
	local by_name = {}
	local in_degree = {}
	local dependents = {}

	for _, spec in ipairs(specs) do
		if by_name[spec.name] then
			error("pack: duplicate spec name: " .. spec.name)
		end
		by_name[spec.name] = spec
		in_degree[spec.name] = 0
		dependents[spec.name] = dependents[spec.name] or {}
	end

	for _, spec in ipairs(specs) do
		for _, dep_name in ipairs(spec.after) do
			if by_name[dep_name] then
				in_degree[spec.name] = in_degree[spec.name] + 1
				table.insert(dependents[dep_name], spec.name)
			else
				vim.notify(
					"pack: "
						.. spec.name
						.. " depends on unknown plugin '"
						.. dep_name
						.. "' (is it disabled or misspelled?)",
					vim.log.levels.WARN
				)
			end
		end
	end

	local queue = {}
	for _, spec in ipairs(specs) do
		if in_degree[spec.name] == 0 then
			table.insert(queue, spec)
		end
	end
	-- Order the ready queue: priority descending, name ascending as tiebreak.
	local function sort_queue()
		table.sort(queue, function(a, b)
			if a.priority ~= b.priority then
				return a.priority > b.priority
			end
			return a.name < b.name
		end)
	end

	sort_queue()

	local sorted = {}
	while #queue > 0 do
		local current = table.remove(queue, 1)
		table.insert(sorted, current)

		for _, dep_name in ipairs(dependents[current.name]) do
			in_degree[dep_name] = in_degree[dep_name] - 1
			if in_degree[dep_name] == 0 then
				table.insert(queue, by_name[dep_name])
			end
		end

		sort_queue()
	end

	if #sorted ~= #specs then
		local missing = {}
		for _, spec in ipairs(specs) do
			if in_degree[spec.name] > 0 then
				table.insert(missing, spec.name)
			end
		end
		error("pack: circular dependency: " .. table.concat(missing, ", "))
	end

	return sorted
end

--- Register `PackChanged` autocmd hooks for specs with a `build` field.
--- vim.pack fires `nvim_exec_autocmds("PackChanged", ...)` directly, so the
--- autocmd must be registered on the `PackChanged` event itself (not
--- `User` + pattern), or the hooks would never match.
---@param specs pack.Spec[]
---@param is_startup fun(): boolean
local function register_build_hooks(specs, is_startup)
	-- Create/clear the augroup unconditionally, so re-registration always
	-- replaces hooks from a previous setup() (even when no builds remain).
	local group =
		vim.api.nvim_create_augroup("pack_build_hooks", { clear = true })

	local hooks = {}
	for _, spec in ipairs(specs) do
		if spec.build then
			hooks[spec.name] = spec.build
		end
	end

	if next(hooks) == nil then
		return
	end

	-- Deferred startup hooks. Note: a re-registration while this is non-empty
	-- (setup() called twice during init) would drop the queued items; this
	-- config calls setup() once per session, so the invariant is just documented.
	local pending = {}

	---@param name string
	---@param data table
	---@param deferred boolean Whether this hook was deferred from startup installs.
	local function run_build_hook(name, data, deferred)
		local hook = hooks[name]
		if not hook then
			return
		end

		-- Install/update events can fire before the plugin's code is on the
		-- runtimepath; load it so the hook can use its commands/functions.
		-- (Deferred startup hooks skip this: the rtp is complete at VimEnter.)
		if not data.active and not deferred then
			pcall(vim.cmd.packadd, name)
		end

		local ok, err
		if type(hook) == "string" and hook:sub(1, 1) == ":" then
			-- closure form: `vim.cmd` is typed as function+table, which pcall's
			-- fn parameter rejects
			local cmd = hook:sub(2)
			ok, err = pcall(function()
				vim.cmd(cmd)
			end)
		elseif type(hook) == "string" then
			vim.notify(
				"pack: build '"
					.. hook
					.. "' for "
					.. name
					.. " is not a ':'-command and was ignored",
				vim.log.levels.WARN
			)
		elseif type(hook) == "function" then
			ok, err =
				pcall(hook, { name = name, path = data.path, kind = data.kind })
		end
		if ok == false then
			vim.notify(
				"pack: build hook failed for " .. name .. ": " .. tostring(err),
				vim.log.levels.ERROR
			)
		end
	end

	vim.api.nvim_create_autocmd("PackChanged", {
		group = group,
		callback = function(ev)
			local data = ev.data or {}
			local name = (data.spec or {}).name
			local kind = data.kind

			if not name or not hooks[name] then
				return
			end
			if kind ~= "install" and kind ~= "update" then
				return
			end
			if is_startup() then
				-- Startup installs: the plugin's files are not on the runtimepath
				-- yet and the user config is still loading; defer until VimEnter,
				-- when every plugin is loaded and sourced.
				pending[#pending + 1] = { name = name, data = data }
				return
			end
			run_build_hook(name, data, false)
		end,
	})

	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		once = true,
		callback = function()
			for _, item in ipairs(pending) do
				run_build_hook(item.name, item.data, true)
			end
			pending = {}
		end,
	})
end

--- Project specs onto the shape accepted by `vim.pack.add` (full URLs,
--- explicit names, version passthrough).
---@param specs pack.Spec[]
---@return vim.pack.Spec[]
local function build_pack_specs(specs)
	local pack_specs = {}
	for _, spec in ipairs(specs) do
		local pack_spec = { src = expand_url(spec.src), name = spec.name }
		if spec.version then
			pack_spec.version = spec.version
		end
		table.insert(pack_specs, pack_spec)
	end
	return pack_specs
end

---@param spec pack.Spec
---@return table|nil
local function resolve_opts(spec)
	local opts = spec.opts
	if opts == nil then
		return nil
	end
	if type(opts) == "function" then
		return opts()
	end
	return opts
end

--- Configure a single spec: a custom `config` function wins; otherwise, when
--- `opts` is present, `require` the resolved module and call its `setup(opts)`.
---@param spec pack.Spec
local function configure(spec)
	local opts = resolve_opts(spec)
	if spec.config then
		spec.config(opts or {})
	elseif opts then
		local module = resolve_module(spec)
		local ok, mod = pcall(require, module)
		if ok and type(mod) == "table" and mod.setup then
			mod.setup(opts)
		elseif not ok then
			vim.notify(
				"pack: failed to require '"
					.. module
					.. "' for "
					.. spec.name
					.. " (set spec.module to override)",
				vim.log.levels.WARN
			)
		else
			-- Non-table modules (e.g. a file returning `true`) land here too;
			-- the type check keeps `mod.setup` from raising on them.
			vim.notify(
				"pack: module '"
					.. module
					.. "' for "
					.. spec.name
					.. " has no setup() (set spec.config to configure it)",
				vim.log.levels.WARN
			)
		end
	elseif spec.opts and opts == nil then
		vim.notify(
			"pack: opts function for "
				.. spec.name
				.. " returned nil; setup skipped",
			vim.log.levels.WARN
		)
	end
end

--- Define the `:PackUpdate` user command (bang = apply immediately, args = plugin names).
local function register_commands()
	vim.api.nvim_create_user_command("PackUpdate", function(args)
		local names = #args.fargs > 0 and args.fargs or nil
		vim.pack.update(names, { force = args.bang })
	end, {
		bang = true,
		force = true, -- re-registration on repeated setup() must not raise
		nargs = "*",
		desc = "Update plugins managed by vim.pack (:PackUpdate! applies immediately)",
	})

	--- Define the `:PackDelete` user command (bang = force removal, args = plugin names).
	--- Unlike `vim.pack.update`, `vim.pack.del` requires an explicit name list (nil
	--- fails its validation), so empty args warn instead of delegating.
	vim.api.nvim_create_user_command("PackDelete", function(args)
		if #args.fargs == 0 then
			vim.notify(
				"PackDelete: no plugin names given (e.g. :PackDelete nvim-lspconfig)",
				vim.log.levels.WARN
			)
			return
		end
		vim.pack.del(args.fargs, { force = args.bang })
	end, {
		bang = true,
		force = true, -- re-registration on repeated setup() must not raise
		nargs = "*",
		desc = "Delete plugins from disk via vim.pack (:PackDelete! forces; remove the spec from lua/plugins first or the plugin returns on restart)",
	})
end

--- Collect specs from `opts.plugins_dir`, topologically sort them, run
--- `init` hooks, register build hooks, hand the resolved specs to
--- `opts.pack_add` (default `vim.pack.add`), then configure each plugin.
---@param opts? pack.SetupOpts
function M.setup(opts)
	local defaults = {
		plugins_dir = vim.fn.stdpath("config") .. "/lua/plugins",
		pack_add = vim.pack.add,
	}
	opts = vim.tbl_extend("force", defaults, opts or {})
	-- Explicit nil in `opts` would otherwise override the defaults (force).
	opts.plugins_dir = opts.plugins_dir or defaults.plugins_dir
	opts.pack_add = opts.pack_add or defaults.pack_add

	local specs = vim.tbl_filter(is_enabled, collect_specs(opts.plugins_dir))
	if #specs == 0 then
		vim.notify(
			"pack: no specs found in "
				.. opts.plugins_dir
				.. " (check the path?)",
			vim.log.levels.WARN
		)
	end
	local sorted = topo_sort(specs)

	for _, spec in ipairs(sorted) do
		if spec.init then
			spec.init()
		end
	end

	register_build_hooks(sorted, opts.is_startup or function()
		return vim.v.vim_did_init == 0
	end)
	register_commands()
	opts.pack_add(build_pack_specs(sorted))

	for _, spec in ipairs(sorted) do
		local ok, err = pcall(configure, spec)
		if not ok then
			vim.notify(
				"pack: error configuring " .. spec.name .. ": " .. tostring(err),
				vim.log.levels.ERROR
			)
		end
	end
end

return M
