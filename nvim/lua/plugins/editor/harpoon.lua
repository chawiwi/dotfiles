return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function(_, opts)
		require("harpoon"):setup(opts or {})
	end,
}
