local in_kitty = vim.env.KITTY_WINDOW_ID ~= nil or vim.env.TERM == "xterm-kitty"

return {
	"3rd/image.nvim",
	enabled = in_kitty,
	build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
	opts = {
		processor = "magick_cli",
		backend = "kitty", -- Kitty will provide the best experience, but you need a compatible terminal
		integrations = {
			-- image.nvim enables markdown integration by default; disable it explicitly
			-- because it currently trips over markdown treesitter parsing on Neovim 0.12.x.
			markdown = { enabled = false },
		},
		max_width = 100, -- tweak to preference
		max_height = 12, -- ^
		max_height_window_percentage = math.huge, -- this is necessary for a good experience
		max_width_window_percentage = math.huge,
		window_overlap_clear_enabled = true,
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
	},
}
