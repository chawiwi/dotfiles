return {
	{ "rcarriga/cmp-dap", lazy = true }, -- nvim-cmp source (we consume via compat)

	{
		"Saghen/blink.compat",
		version = "2.*",
		lazy = true,
		opts = {
			sources = {
				{
					name = "dap", -- name of the nvim-cmp source
					-- Optional: only enable in DAP buffers
					should_enable = function()
						local ft = vim.bo.filetype
						return ft == "dap-repl" or ft == "dapui_watches" or ft == "dapui_hover" or ft == "dap-view"
					end,
				},
			},
		},
	},
}
