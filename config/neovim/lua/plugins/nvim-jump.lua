return {
	"yorickpeterse/nvim-jump",
	config = function()
		vim.keymap.set({ "n", "x", "o" }, "s", require("jump").start, {})
	end,
}
