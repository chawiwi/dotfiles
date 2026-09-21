vim.pack.add({
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/mfussenegger/nvim-dap-python" },
	{ src = "https://github.com/igorlfs/nvim-dap-view", version = vim.version.range("1.*") },
})

local dap = require("dap")
local dap_view = require("dap-view")
local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

require("dap-python").setup(vim.fn.executable(debugpy) == 1 and debugpy or "python3")
dap.defaults.fallback.switchbuf = "usevisible,usetab,newtab"

dap_view.setup({
	auto_toggle = true,
	winbar = { controls = { enabled = true } },
	virtual_text = { enabled = true, position = "inline" },
})

dap.adapters["debugpy-remote"] = function(callback, config)
	callback({
		type = "server",
		host = (config.connect and config.connect.host) or "127.0.0.1",
		port = (config.connect and config.connect.port) or 5679,
		options = { source_filetype = "python" },
	})
end

local function active_mount()
	local ok, mount_point = pcall(require, "sshfs.lib.mount_point")
	if not ok then
		return nil
	end

	local file = vim.api.nvim_buf_get_name(0)
	local best
	for _, mount in ipairs(mount_point.list_active()) do
		local path = mount.mount_path
		if type(path) == "string" and (file == path or vim.startswith(file, path .. "/")) then
			if not best or #path > #best.mount_path then
				best = mount
			end
		end
	end
	return best
end

vim.api.nvim_create_user_command("DapAttachRemoteRoot", function(command)
	local args = vim.split(command.args, "%s+", { trimempty = true })
	local mount = active_mount()
	local host = args[1] or (mount and mount.host) or vim.fn.input("SSH host label: ")
	local remote_root = args[2] or (mount and mount.remote_path) or vim.fn.input("Remote root: ")
	local local_root = mount and mount.mount_path or vim.fn.input("Local mount root: ")
	local port = tonumber(args[3]) or 5679

	if host == "" or remote_root == "" or local_root == "" then
		vim.notify("Host, remote root, and local mount root are required", vim.log.levels.ERROR)
		return
	end

	dap.run({
		type = "debugpy-remote",
		request = "attach",
		name = ("Attach %s:%d"):format(host, port),
		connect = { host = "127.0.0.1", port = port },
		pathMappings = { { localRoot = local_root, remoteRoot = remote_root } },
		justMyCode = false,
		subProcess = true,
	})
end, { nargs = "*" })

local tunnel_job
vim.api.nvim_create_user_command("RDbgTunnelStart", function(command)
	local args = vim.split(command.args, "%s+", { trimempty = true })
	local target = args[1] or vim.fn.input("SSH target: ")
	local port = tonumber(args[2]) or 5679
	if target == "" then
		return
	end
	if tunnel_job then
		vim.notify("Debug tunnel is already running", vim.log.levels.WARN)
		return
	end
	tunnel_job = vim.fn.jobstart({ "ssh", "-N", "-L", ("%d:127.0.0.1:%d"):format(port, port), target }, {
		on_exit = function()
			tunnel_job = nil
		end,
	})
	if tunnel_job <= 0 then
		tunnel_job = nil
		vim.notify("Failed to start debug tunnel", vim.log.levels.ERROR)
	end
end, { nargs = "*" })

vim.api.nvim_create_user_command("RDbgTunnelStop", function()
	if tunnel_job then
		vim.fn.jobstop(tunnel_job)
		tunnel_job = nil
	end
end, {})

local map = vim.keymap.set
map("n", "<F5>", dap.continue, { desc = "Debug continue" })
map("n", "<F1>", dap.step_into, { desc = "Debug step into" })
map("n", "<F2>", dap.step_over, { desc = "Debug step over" })
map("n", "<F3>", dap.step_out, { desc = "Debug step out" })
map("n", "<F4>", dap.run_to_cursor, { desc = "Debug run to cursor" })
map("n", "<F6>", dap.run_last, { desc = "Debug run last" })
map("n", "<F7>", dap_view.toggle, { desc = "Debug toggle UI" })
map("n", "<F8>", dap.reverse_continue, { desc = "Debug reverse continue" })
map("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug toggle breakpoint" })
map("n", "<leader>B", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug conditional breakpoint" })
map({ "n", "x" }, "<leader>dw", dap_view.add_expr, { desc = "Debug add watch" })
map({ "n", "x" }, "<leader>de", dap_view.hover, { desc = "Debug evaluate expression" })
map("n", "<leader>dv", dap_view.virtual_text_toggle, { desc = "Debug toggle inline values" })
map("n", "<leader>ds", "<CMD>RDbgTunnelStart<CR>", { desc = "Debug start SSH tunnel" })
map("n", "<leader>dx", "<CMD>RDbgTunnelStop<CR>", { desc = "Debug stop SSH tunnel" })
map("n", "<leader>da", "<CMD>DapAttachRemoteRoot<CR>", { desc = "Debug attach remote" })
