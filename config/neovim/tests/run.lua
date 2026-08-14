--- Test runner entrypoint: `nvim -l tests/run.lua <spec-file>`.
---
--- Runs one busted spec file headlessly with only the config dir and plenary
--- on the runtimepath (no user config is loaded). Exit code is 0/1/2 for
--- success/failure/error (plenary busted's `cq` handling).

---@type string
local file = vim.env.NVIM_TEST_SPEC
assert(file, "NVIM_TEST_SPEC must point at a spec file")

vim.opt.runtimepath:prepend(vim.fn.stdpath("config"))
vim.opt.runtimepath:prepend(
	vim.fn.expand("$HOME")
		.. "/.local/share/nvim/site/pack/core/opt/plenary.nvim"
)

require("plenary.busted").run(file)
