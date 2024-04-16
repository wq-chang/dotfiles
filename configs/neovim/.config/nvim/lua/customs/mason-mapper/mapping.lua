local M = {}

-- conform formatter to mason package mapping
-- https://mason-registry.dev/registry/list
M.conform_to_mason = {
	-- alejandra
	["asmfmt"] = "asmfmt",
	["ast-grep"] = "ast-grep",
	-- astyle
	-- auto_optional
	-- autocorrect
	["autoflake"] = "autoflake",
	["autopep8"] = "autopep8",
	-- awk
	-- bean-format
	["beautysh"] = "beautysh",
	["bibtex-tidy"] = "bibtex-tidy",
	-- biome-check
	["biome"] = "biome",
	["black"] = "black",
	["blade-formatter"] = "blade-formatter",
	["blue"] = "blue",
	["buf"] = "buf",
	["buildifier"] = "buildifier",
	["cbfmt"] = "cbfmt",
	["clang_format"] = "clang-format",
	-- cljstyle
	["cmake_format"] = "cmakelang",
	["codespell"] = "codespell",
	["csharpier"] = "csharpier",
	-- cue_fmt
	["darker"] = "darker",
	-- dart_format
	["deno_fmt"] = "deno",
	-- dfmt
	["djlint"] = "djlint",
	["dprint"] = "dprint",
	["easy-coding-standard"] = "easy-coding-standard",
	["elm_format"] = "elm-format",
	-- erb_format
	["eslint_d"] = "eslint_d",
	["fantomas"] = "fantomas",
	-- fish_indent
	["fixjson"] = "fixjson",
	-- fnlfmt
	["fourmolu"] = "fourmolu",
	["gci"] = "gci",
	["gdformat"] = "gdtoolkit",
	["gersemi"] = "gersemi",
	-- gn
	-- gofmt
	["gofumpt"] = "gofumpt",
	["goimports-reviser"] = "goimports-reviser",
	["goimports"] = "goimports",
	["golines"] = "golines",
	["google-java-format"] = "google-java-format",
	["htmlbeautifier"] = "htmlbeautifier",
	-- indent
	-- init
	-- injected
	["isort"] = "isort",
	["joker"] = "joker",
	["jq"] = "jq",
	["jsonnetfmt"] = "jsonnetfmt",
	-- just
	["ktlint"] = "ktlint",
	["latexindent"] = "latexindent",
	["markdown-toc"] = "markdown-toc",
	["markdownlint-cli2"] = "markdownlint-cli2",
	["markdownlint"] = "markdownlint",
	["mdformat"] = "mdformat",
	["mdslw"] = "mdslw",
	-- mix
	-- nixfmt
	["nixpkgs_fmt"] = "nixpkgs-fmt",
	["ocamlformat"] = "ocamlformat",
	-- opa_fmt
	-- packer_fmt
	-- pangu
	-- perlimports
	-- perltidy
	-- pg_format
	["php_cs_fixer"] = "php-cs-fixer",
	["phpcbf"] = "phpcbf",
	-- phpinsights
	["pint"] = "pint",
	["prettier"] = "prettier",
	["prettierd"] = "prettierd",
	["pretty-php"] = "pretty-php",
	-- puppet-lint
	["reorder-python-imports"] = "reorder-python-imports",
	-- rescript-format
	["rubocop"] = "rubocop",
	["rubyfmt"] = "rubyfmt",
	-- ruff
	["ruff_fix"] = "ruff",
	["ruff_format"] = "ruff",
	["rufo"] = "rufo",
	["rustfmt"] = "rustfmt",
	["rustywind"] = "rustywind",
	-- scalafmt
	["shellcheck"] = "shellcheck",
	["shellharden"] = "shellharden",
	["shfmt"] = "shfmt",
	["sql_formatter"] = "sql-formatter",
	["sqlfluff"] = "sqlfluff",
	["sqlfmt"] = "sqlfmt",
	-- squeeze_blanks
	["standardjs"] = "standardjs",
	["standardrb"] = "standardrb",
	["stylelint"] = "stylelint",
	-- styler
	["stylua"] = "stylua",
	-- swift_format
	-- swiftformat
	["taplo"] = "taplo",
	["templ"] = "templ",
	-- terraform_fmt
	-- terragrunt_hclfmt
	["tlint"] = "tlint",
	-- trim_newlines
	-- trim_whitespace
	-- twig-cs-fixer
	["typos"] = "typos",
	-- typstfmt
	-- uncrustify
	["usort"] = "usort",
	["xmlformat"] = "xmlformatter",
	-- xmllint
	["yamlfix"] = "yamlfix",
	["yamlfmt"] = "yamlfmt",
	["yapf"] = "yapf",
	["yq"] = "yq",
	-- zigfmt
	["zprint"] = "zprint",
}

M.nvimlint_to_mason = {
	["actionlint"] = "actionlint",
	["ansible_lint"] = "ansible_lint",
	["buf_lint"] = "buf",
	["buildifier"] = "buildifier",
	["cfn_lint"] = "cfn-lint",
	["checkstyle"] = "checkstyle",
	["clj_kondo"] = "clj-kondo",
	["cmakelint"] = "cmakelint",
	["codespell"] = "codespell",
	["cpplint"] = "cpplint",
	["cspell"] = "cspell",
	["curlylint"] = "curlylint",
	["djlint"] = "djlint",
	["erb_lint"] = "erb-lint",
	["eslint_d"] = "eslint_d",
	["flake8"] = "flake8",
	["gdlint"] = "gdtoolkit",
	["golangcilint"] = "golangci-lint",
	["hadolint"] = "hadolint",
	["jsonlint"] = "jsonlint",
	["ktlint"] = "ktlint",
	["luacheck"] = "luacheck",
	["markdownlint"] = "markdownlint",
	["mypy"] = "mypy",
	["phpcs"] = "phpcs",
	["phpmd"] = "phpmd",
	["phpstan"] = "phpstan",
	["proselint"] = "proselint",
	["pydocstyle"] = "pydocstyle",
	["pylint"] = "pylint",
	["revive"] = "revive",
	["rstcheck"] = "rstcheck",
	["rubocop"] = "rubocop",
	["ruff"] = "ruff",
	["selene"] = "selene",
	["shellcheck"] = "shellcheck",
	["sqlfluff"] = "sqlfluff",
	["standardrb"] = "standardrb",
	["stylelint"] = "stylelint",
	["solhint"] = "solhint",
	["vale"] = "vale",
	["vint"] = "vint",
	["vulture"] = "vulture",
	["yamllint"] = "yamllint",
	["tfsec"] = "tfsec",
	["tflint"] = "tflint",
}

M.dap_to_mason = {
	["python"] = "debugpy",
	["cppdbg"] = "cpptools",
	["delve"] = "delve",
	["node2"] = "node-debug2-adapter",
	["chrome"] = "chrome-debug-adapter",
	["firefox"] = "firefox-debug-adapter",
	["php"] = "php-debug-adapter",
	["coreclr"] = "netcoredbg",
	["js"] = "js-debug-adapter",
	["codelldb"] = "codelldb",
	["bash"] = "bash-debug-adapter",
	["javadbg"] = "java-debug-adapter",
	["javatest"] = "java-test",
	["mock"] = "mockdebug",
	["puppet"] = "puppet-editor-services",
	["elixir"] = "elixir-ls",
	["kotlin"] = "kotlin-debug-adapter",
	["dart"] = "dart-debug-adapter",
	["haskell"] = "haskell-debug-adapter",
}

return M
