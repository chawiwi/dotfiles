vim.pack.add({
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
})

local map = vim.keymap.set
map("n", "<C-h>", "<CMD><C-U>TmuxNavigateLeft<CR>", { desc = "Tmux navigate left" })
map("n", "<C-j>", "<CMD><C-U>TmuxNavigateDown<CR>", { desc = "Tmux navigate down" })
map("n", "<C-k>", "<CMD><C-U>TmuxNavigateUp<CR>", { desc = "Tmux navigate up" })
map("n", "<C-l>", "<CMD><C-U>TmuxNavigateRight<CR>", { desc = "Tmux navigate right" })
map("n", "<C-\\>", "<CMD><C-U>TmuxNavigatePrevious<CR>", { desc = "Tmux navigate previous" })

-- Sidekick's CLI runs in a terminal buffer. Leave terminal
-- input first, then let vim-tmux-navigator select an adjacent window or pane.
map("t", "<C-h>", "<C-\\><C-n><CMD><C-U>TmuxNavigateLeft<CR>", { desc = "Tmux navigate left" })
map("t", "<C-j>", "<C-\\><C-n><CMD><C-U>TmuxNavigateDown<CR>", { desc = "Tmux navigate down" })
map("t", "<C-k>", "<C-\\><C-n><CMD><C-U>TmuxNavigateUp<CR>", { desc = "Tmux navigate up" })
map("t", "<C-l>", "<C-\\><C-n><CMD><C-U>TmuxNavigateRight<CR>", { desc = "Tmux navigate right" })
map("t", "<C-\\>", "<C-\\><C-n><CMD><C-U>TmuxNavigatePrevious<CR>", { desc = "Tmux navigate previous" })
