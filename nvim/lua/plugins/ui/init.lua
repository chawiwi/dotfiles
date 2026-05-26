local config_dir = vim.fn.stdpath("config") .. "/lua/plugins/ui/"

local function load(spec)
	return dofile(config_dir .. spec)
end

return {
	load("bufferline.lua"),
	load("image.lua"),
	load("img-clip.lua"),
	load("kitty-scrollback.lua"),
	load("lualine.lua"),
	load("markview.lua"),
	load("stay-centered.lua"),
	load("trouble.nvim.lua"),
	load("vim-tmux-navigator.lua"),
	load("virt-column.lua"),
}
