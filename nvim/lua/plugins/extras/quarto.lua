-- lua/plugins/quarto.lua
return {
	{
		"quarto-dev/quarto-nvim",
		ft = { "quarto", "markdown", "qmd" },
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- no need for slime if we use molten
		},
		config = function()
			require("quarto").setup({
				codeRunner = {
					enabled = true,
					default_method = "molten", -- <— key line
				},
			})
			-- activate Quarto features in markdown too
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown", "qmd" },
				callback = function()
					pcall(function()
						require("quarto").activate()
					end)
				end,
			})
		end,
	},
}
