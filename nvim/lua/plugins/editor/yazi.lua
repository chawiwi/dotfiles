return {
	{
		"mikavilpas/yazi.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Yazi",
		keys = {
			{ "<leader>y", "<cmd>Yazi<cr>", desc = "Yazi: open at current file" },
			{ "<leader>Y", "<cmd>Yazi cwd<cr>", desc = "Yazi: open in cwd" },
			{ "<leader>yy", "<cmd>Yazi toggle<cr>", desc = "Yazi: resume last session" },
		},
		opts = {},
	},
}
