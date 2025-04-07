return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
		on_attach = function(buffer)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
			end

			local function toggle_inline_diff()
				gs.toggle_numhl()
				gs.toggle_deleted()
				gs.toggle_word_diff()
				gs.toggle_linehl()
			end

			-- stylua: ignore start
			map("n", "]h", gs.next_hunk, "Next Hunk")
			map("n", "[h", gs.prev_hunk, "Prev Hunk")
			map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<cr>", "Stage Hunk")
			map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<cr>", "Reset Hunk")
			map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
			map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
			map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
			map("n", "<leader>gp", gs.preview_hunk_inline, "Preview Hunk Inline")
			map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")
			map("n", "<leader>gB", gs.toggle_current_line_blame, "Blame Line")
			map("n", "<leader>gd", function() gs.diffthis("~") end, "Diff This ~")
			map("n", "<leader>gD", gs.diffthis, "Diff This")
			map("n", "<leader>gt", toggle_inline_diff, "Toggle inline diff")
			map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", "GitSigns Select Hunk")
			-- stylua: ignore end
		end,
	},
}
