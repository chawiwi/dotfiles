vim.pack.add({
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/folke/tokyonight.nvim" },
})

-- require("kanagawa").load("wave")
-- require("catppuccin").load("mocha")
require("tokyonight").setup({ style = "night" })
vim.cmd.colorscheme("tokyonight")
