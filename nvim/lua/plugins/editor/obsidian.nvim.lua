local function is_wsl()
	local release = vim.uv.os_uname().release:lower()
	return release:find("microsoft", 1, true) ~= nil
end

local function expand(path)
	return vim.fn.expand(path)
end

local function first_existing_dir(paths)
	for _, path in ipairs(paths) do
		if path and path ~= "" then
			local expanded = expand(path)
			if vim.fn.isdirectory(expanded) == 1 then
				return expanded
			end
		end
	end
end

local function workspace_path(name, default_path)
	local env_name = "OBSIDIAN_" .. name:upper() .. "_VAULT"
	local env_path = vim.env[env_name]
	if env_path and env_path ~= "" then
		return expand(env_path)
	end

	local candidates = { default_path }
	if is_wsl() and vim.env.USER and vim.env.USER ~= "" then
		table.insert(candidates, string.format("/mnt/c/Users/%s/vaults/%s", vim.env.USER, name))
		table.insert(candidates, string.format("/mnt/c/Users/%s/Documents/Obsidian/%s", vim.env.USER, name))
	end

	return first_existing_dir(candidates) or expand(default_path)
end

local function open_in_obsidian(uri)
	if is_wsl() then
		if vim.fn.executable("wsl-open") == 1 then
			vim.system({ "wsl-open", uri }, { detach = true })
			return
		end
		if vim.fn.executable("powershell.exe") == 1 then
			local escaped_uri = uri:gsub("'", "''")
			vim.system(
				{ "powershell.exe", "-NoProfile", "-Command", string.format("Start-Process '%s'", escaped_uri) },
				{ detach = true }
			)
			return
		end
	end

	vim.ui.open(uri)
end

local function obsidian_attachment_dir()
	local attachment_folder = Obsidian.opts.attachments.folder or "attachments"
	local note_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))

	if vim.startswith(attachment_folder, ".") then
		return vim.fs.joinpath(note_dir, attachment_folder)
	end

	local vault_relative = attachment_folder:gsub("^/+", "")
	return vim.fs.joinpath(tostring(Obsidian.dir), vault_relative)
end

local function paste_obsidian_image()
	local ok, img_clip = pcall(require, "img-clip")
	if not ok then
		vim.notify("img-clip.nvim is not available", vim.log.levels.ERROR)
		return
	end

	local builtin = require("obsidian.builtin")

	img_clip.paste_image({
		dir_path = obsidian_attachment_dir,
		file_name = function()
			return Obsidian.opts.attachments.img_name_func()
		end,
		prompt_for_file_name = Obsidian.opts.attachments.confirm_img_paste,
		relative_to_current_file = false,
		relative_template_path = false,
		use_absolute_path = false,
		url_encode_path = false,
		download_images = false,
		template = function(context)
			return builtin.img_text_func(context.file_path)
		end,
	})
end

local function obsidian_workspace_command(data)
	local Workspace = require("obsidian.workspace")

	if data.args and data.args ~= "" then
		Workspace.set(data.args)
		return
	end

	local workspace_names = {}
	for _, ws in ipairs(Obsidian.workspaces) do
		if ws.name ~= ".obsidian.wiki" then
			table.insert(workspace_names, ws.name)
		end
	end

	vim.ui.select(workspace_names, { prompt = "Obsidian Workspace" }, function(choice)
		if choice then
			Workspace.set(choice)
		end
	end)
end

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- use latest release, remove to use latest commit
	ft = { "markdown", "quarto" },
	cmd = "Obsidian",
	dependencies = {
		"HakonHarnes/img-clip.nvim",
	},
	keys = {
		{ "<leader>OO", "<cmd>Obsidian open<CR>", desc = "Obsidian Open App" },
		{ "<leader>On", "<cmd>Obsidian new<CR>", desc = "Obsidian New Note" },
		{ "<leader>Oq", "<cmd>Obsidian quick_switch<CR>", desc = "Obsidian Quick Switch" },
		{ "<leader>Os", "<cmd>Obsidian search<CR>", desc = "Obsidian Search Notes" },
		{ "<leader>Od", "<cmd>Obsidian today<CR>", desc = "Obsidian Today" },
		{ "<leader>OD", "<cmd>Obsidian dailies<CR>", desc = "Obsidian Dailies" },
		{ "<leader>OT", "<cmd>Obsidian new_from_template<CR>", desc = "Obsidian New From Template" },
		{ "<leader>Ow", "<cmd>Obsidian workspace<CR>", desc = "Obsidian Workspace" },
	},
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "home",
				path = workspace_path("home", "~/vaults/home"),
			},
			{
				name = "work",
				path = workspace_path("work", "~/vaults/work"),
			},
		},
		picker = {
			name = "snacks.pick",
		},
		open = {
			func = open_in_obsidian,
		},
		callbacks = {
			post_setup = function()
				require("obsidian.commands").register("workspace", {
					nargs = "?",
					func = obsidian_workspace_command,
				})
			end,
			enter_note = function()
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = desc })
				end

				map("n", "<leader>Ob", "<cmd>Obsidian backlinks<CR>", "Obsidian Backlinks")
				map("n", "<leader>Oc", "<cmd>Obsidian toc<CR>", "Obsidian Table of Contents")
				map("n", "<leader>Ol", "<cmd>Obsidian links<CR>", "Obsidian Links")
				map("n", "<leader>Op", paste_obsidian_image, "Obsidian Paste Image")
				map("n", "<leader>Or", "<cmd>Obsidian rename<CR>", "Obsidian Rename Note")
				map("n", "<leader>Ot", "<cmd>Obsidian template<CR>", "Obsidian Insert Template")
				map("n", "<leader>Ox", "<cmd>Obsidian toggle_checkbox<CR>", "Obsidian Toggle Checkbox")
				map("x", "<leader>Oe", "<cmd>Obsidian extract_note<CR>", "Obsidian Extract Note")
				map("x", "<leader>Ol", "<cmd>Obsidian link<CR>", "Obsidian Link Selection")
				map("x", "<leader>On", "<cmd>Obsidian link_new<CR>", "Obsidian New Linked Note")
			end,
		},
	},
}
