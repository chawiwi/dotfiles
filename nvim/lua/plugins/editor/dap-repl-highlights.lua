return {
	"LiadOz/nvim-dap-repl-highlights",
	dependencies = { "mfussenegger/nvim-dap" },
	-- Ensure this runs before nvim-treesitter config
	priority = 1000,
	config = function()
		require("nvim-dap-repl-highlights").setup()
	end,
}
