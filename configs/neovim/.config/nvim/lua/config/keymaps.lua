local map = vim.keymap.set

vim.g.mapleader = " "

map("i", "jk", "<esc>", {})

-- Clear search with <esc>
map(
	{ "i", "n" },
	"<esc>",
	"<cmd>noh<cr><esc>",
	{ desc = "Escape and clear hlsearch" }
)

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
map("n", "<leader>wc", "<C-W>c", { desc = "Close window", remap = true })
map("n", "<leader>ws", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>wv", "<C-W>v", { desc = "Split window right", remap = true })
