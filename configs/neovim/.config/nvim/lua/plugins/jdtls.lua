local function jdtls_setup()
	local home = os.getenv("HOME")
	local root_markers =
		{ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
	local root_dir = require("jdtls.setup").find_root(root_markers)
	local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
	local workspace_dir = home .. "/.cache/jdtls/workspace" .. project_name
	local mason_packages_path = vim.fn.stdpath("data") .. "/mason/packages"
	local jdtls_path = mason_packages_path .. "/jdtls"
	local lombok_path = jdtls_path .. "/lombok.jar"
	local config_path
	if vim.fn.has("mac") == 1 then
		config_path = jdtls_path .. "/config_mac"
	elseif vim.fn.has("unix") == 1 then
		config_path = jdtls_path .. "/config_linux"
	elseif vim.fn.has("win32") == 1 then
		config_path = jdtls_path .. "/config_win"
	end
	local path_to_jar =
		vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

	local config = {
		flags = {
			allow_incremental_sync = true,
		},
	}

	config.cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"-javaagent:" .. lombok_path,
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-jar",
		path_to_jar,
		"-configuration",
		config_path,
		"-data",
		workspace_dir,
	}

	config.settings = {
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
	}
	local m2_settings_file = "/.m2/settings.xml"
	local user_m2_settings_path = vim.fn.glob(
		require("utils.file").find_marker_in_parent(root_markers)
			.. m2_settings_file
	)
	local global_m2_settings_path = vim.fn.glob(home .. m2_settings_file)
	if user_m2_settings_path ~= "" or global_m2_settings_path ~= "" then
		local configuration = { maven = {} }
		if user_m2_settings_path ~= "" then
			configuration.maven.userSettings = user_m2_settings_path
		end
		if global_m2_settings_path ~= "" then
			configuration.maven.globalSettings = global_m2_settings_path
		end
		config.settings.java.configuration = configuration
	end

	local extendedClientCapabilities =
		require("jdtls").extendedClientCapabilities
	extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

	local bundles = {}

	local jdebug_path = mason_packages_path .. "/java-debug-adapter"
	local jdebug_bundle = vim.split(
		vim.fn.glob(
			jdebug_path
				.. "/extension/server/com.microsoft.java.debug.plugin-*.jar"
		),
		"\n"
	)
	if jdebug_bundle[1] ~= "" then
		vim.list_extend(bundles, jdebug_bundle)
	end

	local jtest_path = mason_packages_path .. "/java-test"
	local jtest_bundle =
		vim.split(vim.fn.glob(jtest_path .. "/extension/server/*.jar"), "\n")
	if jtest_bundle[1] ~= "" then
		vim.list_extend(bundles, jtest_bundle)
	end

	config.init_options = {
		bundles = bundles,
		extendedClientCapabilities = extendedClientCapabilities,
	}

	config.on_attach = function()
		local timer = vim.loop.new_timer()
		-- Delay 2000ms and 0 means "do not repeat"
		timer:start(
			3000,
			0,
			vim.schedule_wrap(require("jdtls.dap").setup_dap_main_class_configs)
		)
	end
	require("jdtls").start_or_attach(config)
end

return {
	{
		"mfussenegger/nvim-jdtls",
		config = function()
			local mapper = require("customs/mason-mapper")
			mapper.add_all_ensure_installed({
				"java-debug-adapter",
				"java-test",
				"jdtls",
			})

			local group =
				vim.api.nvim_create_augroup("java_jdtls", { clear = true })
			local function map(lhs, rhx, opts)
				vim.api.nvim_buf_set_keymap(0, "n", lhs, rhx, opts)
			end
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "java" },
				-- stylua: ignore
				callback = function(_)
					map( "<leader>da", "<cmd>lua require('jdtls.dap').test_class()<cr>", { desc = "Test class" })
					map( "<leader>dm", "<cmd>lua require('jdtls.dap').test_nearest_method()<cr>", { desc = "Test method" })
					map( "<leader>nd", "<cmd>lua require('jdtls.dap').test_nearest_method()<cr>", { desc = "Debug method" })
					jdtls_setup()
				end,
				group = group,
			})
		end,
	},
}
