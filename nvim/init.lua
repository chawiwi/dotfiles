-- Specify load order where it matters
require("options")
require("theme")
-- Load all plugins under this ~/.config/nvim/lua/plugins
local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
local modules = {}

local function collect(dir, prefix)
	for name, type in vim.fs.dir(dir) do
		if type == "file" and name:sub(-4) == ".lua" and name ~= "init.lua" then
			modules[#modules + 1] = prefix .. name:sub(1, -5)
		elseif type == "directory" then
			collect(dir .. "/" .. name, prefix .. name .. ".")
		end
	end
end

collect(plugin_dir, "plugins.")
table.sort(modules)

for _, module in ipairs(modules) do
	require(module)
end

-- Keymaps that import plugin modules must be registered after plugins load.
require("keymaps")
