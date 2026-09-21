vim.pack.add({
	{ src = "https://github.com/esmuellert/vscode-diff.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
})

local map = vim.keymap.set
map("n", "<leader>gv", "<CMD>CodeDiff<CR>", { desc = "Git diff view" })
map("n", "<leader>gh", "<CMD>CodeDiff file HEAD<CR>", { desc = "Git file diff against HEAD" })
map("n", "<leader>gB", "<CMD>CodeDiff origin/HEAD HEAD<CR>", { desc = "Git branch diff" })
