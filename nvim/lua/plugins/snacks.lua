vim.pack.add({ { src = "https://github.com/folke/snacks.nvim" } })

local mini = require("plugins.mini")

local open_packages = function()
	-- plugin-view expects every package to have a string `spec.version`. vim.pack
	-- instead leaves it unset for floating packages and accepts version objects.
	-- Present the installed commit to the viewer, without changing the real specs.
	local pack_get = vim.pack.get
	vim.pack.get = function(...)
		local packages = pack_get(...)
		for index, package in ipairs(packages) do
			package = vim.deepcopy(package)
			package.spec.version = package.rev:sub(1, 10)
			packages[index] = package
		end
		return packages
	end

	local ok, err = pcall(require("plugin-view").open)
	vim.pack.get = pack_get
	if not ok then
		error(err)
	end
end

local dashboard_package_stats = function()
	return {
		align = "center",
		text = {
			{ "⚡ Neovim loaded ", hl = "footer" },
			{ #vim.pack.get() .. " packages", hl = "special" },
		},
	}
end

require("snacks").setup({
	dashboard = {
		enabled = true,
		preset = {
			keys = {
				{
					icon = " ",
					key = "f",
					desc = "Files .",
					action = function()
						mini.pick_files(vim.fn.getcwd())
					end,
				},
				{
					icon = "󰊢 ",
					key = "g",
					desc = "Git files",
					action = function()
						mini.pick_files("~/git_files")
					end,
				},
				{
					icon = " ",
					key = "c",
					desc = "Config files",
					action = function()
						mini.pick_files(vim.fn.stdpath("config"))
					end,
				},
				{ icon = " ", key = "r", desc = "Recent files", action = mini.pick_recent_files },
				{ icon = " ", key = "n", desc = "New buffer", action = "enew" },
				{ icon = " ", key = "p", desc = "Manage packages", action = open_packages },
			},
		},
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
			dashboard_package_stats,
		},
	},
})

vim.api.nvim_create_user_command("PackView", open_packages, { desc = "Manage installed packages" })
vim.keymap.set("n", "<leader>p", open_packages, { desc = "Manage packages" })
