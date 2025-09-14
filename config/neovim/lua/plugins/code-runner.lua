return {
	"CRAG666/code_runner.nvim",
	keys = {
		{
			"<leader>cr",
			function()
				require("code_runner").run_code()
			end,
			desc = "Run code",
		},
	},
	opts = {
		filetype = {
			go = { "go run" },
			java = {
				"cd $dir &&",
				"javac $fileName &&",
				"java $fileNameWithoutExt",
			},
			python = "python -u",
		},
	},
}
