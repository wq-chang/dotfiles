local map = vim.keymap.set

vim.g.mapleader = " "

map("i", "jk", "<esc>", {})

-- Clear search with <esc>
-- stylua: ignore
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Ctrl + Backspace to delete word
map("i", "<C-H>", "<C-W>", { noremap = true })
-- Shift + Enter to enter new line
map("i", "<S-cr>", "<C-o>o", { noremap = true })

-- Navigate windows
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Windows
-- stylua: ignore start
map("n", "<leader>wc", "<C-W>c", { desc = "Close window", remap = true })
map("n", "<leader>ws", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>wv", "<C-W>v", { desc = "Split window right", remap = true })
-- Window resize submode (see plugins/clue.lua): `<leader>w` + j/k/l/h repeats
map("n", "<leader>wj", "<cmd>resize +2<cr>", { desc = "Increase height" })
map("n", "<leader>wk", "<cmd>resize -2<cr>", { desc = "Decrease height" })
map("n", "<leader>wh", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
map("n", "<leader>wl", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })
-- Move window to far edge (builtin `<C-w>H/J/K/L`)
map("n", "<leader>wH", "<C-W>H", { desc = "Move window far left", remap = true })
map("n", "<leader>wJ", "<C-W>J", { desc = "Move window far bottom", remap = true })
map("n", "<leader>wK", "<C-W>K", { desc = "Move window far top", remap = true })
map("n", "<leader>wL", "<C-W>L", { desc = "Move window far right", remap = true })
-- stylua: ignore end

-- Window swap submode (see plugins/clue.lua): `<leader>wx` + h/j/k/l repeats
local function swap_window(direction)
	local cur = vim.api.nvim_get_current_win()
	pcall(function()
		vim.cmd("wincmd " .. direction)
	end)
	local target = vim.api.nvim_get_current_win()
	if target == cur then
		return
	end
	local cur_buf = vim.api.nvim_win_get_buf(cur)
	vim.api.nvim_win_set_buf(cur, vim.api.nvim_win_get_buf(target))
	vim.api.nvim_win_set_buf(target, cur_buf)
end

map("n", "<leader>wxh", function()
	swap_window("h")
end, { desc = "Swap with left window" })
map("n", "<leader>wxj", function()
	swap_window("j")
end, { desc = "Swap with below window" })
map("n", "<leader>wxk", function()
	swap_window("k")
end, { desc = "Swap with above window" })
map("n", "<leader>wxl", function()
	swap_window("l")
end, { desc = "Swap with right window" })

-- Codes
map("n", "<leader>cm", ":%s/\\r//g<cr>", { desc = "Remove ^M character" })

-- Terminal
map("t", "jk", [[<C-\><C-n>]], { noremap = true })
