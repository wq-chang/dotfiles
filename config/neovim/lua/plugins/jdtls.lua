local function build_jdtls_config()
	local home = os.getenv("HOME")
	local root_markers =
		{ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
	local workspace_root = require("jdtls.setup").find_root(root_markers)
	local project_name = workspace_root
			and vim.fn.fnamemodify(workspace_root, ":p:h:t")
		or vim.fn.getcwd():match("([^/]+)$")
	local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

	local config = {
		flags = {
			allow_incremental_sync = true,
		},
		cmd = { "jdtls" },
		-- Explicit so jdtls stays self-contained if lspconfig's lsp/jdtls.lua
		-- is ever absent (its defaults would otherwise be merged in)
		filetypes = { "java" },
		settings = {
			java = {
				references = {
					includeDecompiledSources = true,
				},
				eclipse = {
					downloadSources = true,
				},
				maven = {
					downloadSources = true,
				},
				signatureHelp = { enabled = true },
				contentProvider = { preferred = "fernflower" },
				completion = {
					favoriteStaticMembers = {
						"org.junit.jupiter.api.Assertions.*",
						"org.mockito.Mockito.*",
					},
				},
			},
		},
		init_options = {
			bundles = {},
			extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
		},
		on_attach = function()
			vim.defer_fn(function()
				local ok, dap = pcall(require, "jdtls.dap")
				if ok then
					pcall(dap.setup_dap_main_class_configs)
				end
			end, 3000)
		end,
	}

	local lombok_path = os.getenv("LOMBOK")
	if lombok_path then
		table.insert(config.cmd, "--jvm-arg=-javaagent:" .. lombok_path)
	end
	table.insert(config.cmd, "-data")
	table.insert(config.cmd, workspace_dir)

	local function m2_settings(prefix)
		local path = prefix and prefix .. "/.m2/settings.xml" or nil
		return path and vim.fn.filereadable(path) == 1 and path or nil
	end
	local user_settings = workspace_root and m2_settings(workspace_root) or nil
	local global_settings = m2_settings(home)
	if user_settings or global_settings then
		config.settings.java.configuration = { maven = {} }
		if user_settings then
			config.settings.java.configuration.maven.userSettings =
				user_settings
		end
		if global_settings then
			config.settings.java.configuration.maven.globalSettings =
				global_settings
		end
	end

	local function add_bundles(env_name, pattern)
		local dir = os.getenv(env_name)
		if not dir then
			return
		end
		local files = vim.fn.glob(dir .. pattern, false, true)
		if #files > 0 then
			vim.list_extend(config.init_options.bundles, files)
		end
	end
	add_bundles("JAVA_DEBUG", "/com.microsoft.java.debug.plugin-*.jar")
	add_bundles("JAVA_TEST", "/*.jar")

	config.init_options.extendedClientCapabilities.resolveAdditionalTextEditsSupport =
		true
	return config
end

return {
	src = "mfussenegger/nvim-jdtls",
	config = function()
		local group = vim.api.nvim_create_augroup("java_jdtls", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			group = group,
			callback = function()
				vim.keymap.set(
					"n",
					"<leader>da",
					"<cmd>lua require('jdtls.dap').test_class()<cr>",
					{ buffer = 0, desc = "Test class" }
				)
				vim.keymap.set(
					"n",
					"<leader>dm",
					"<cmd>lua require('jdtls.dap').test_nearest_method()<cr>",
					{ buffer = 0, desc = "Test method" }
				)

				-- Re-assert mini.clue triggers after buffer-local mappings
				local ok, miniclue = pcall(require, "mini.clue")
				if ok then
					miniclue.ensure_buf_triggers(0)
				end

				vim.lsp.config("jdtls", build_jdtls_config())
				vim.lsp.enable("jdtls")
			end,
		})
	end,
}
