return {
	"mfussenegger/nvim-dap",
	dependencies = {
		-- Installs the debug adapters for you
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- Add your own debuggers here
		"leoluz/nvim-dap-go",
		"mfussenegger/nvim-dap-python",
		-- dap-view
		{
			"igorlfs/nvim-dap-view",
			opts = {
				-- keep defaults; just auto open/close with sessions
				winbar = { controls = { enabled = true } },
				auto_toggle = true, -- open/close with sessions
			},
		},
	},
	config = function()
		local dap = require("dap")

		require("mason-nvim-dap").setup({
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_setup = true,
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {},

			-- You'll need to check that you have the required things installed
			-- online, please don't ask me how to install them :)
			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
				-- 'delve',
				"debugpy",
			},
		})

		-- Adapter that honors dynamic host/port (we attach to an SSH tunnel)
		dap.adapters["debugpy-remote"] = function(cb, cfg)
			cb({
				type = "server",
				host = (cfg.connect and cfg.connect.host) or "127.0.0.1",
				port = (cfg.connect and cfg.connect.port) or 5679,
				options = { source_filetype = "python" },
			})
		end

		-- Normalize remote roots
		-- - keeps "~" paths
		-- - keeps Windows drive roots like "C:/work" or "C:\\work" (converts backslashes)
		-- - adds leading slash for relative POSIX paths
		-- - keeps "/" as-is
		local function normalize_remote_root(path)
			if not path or path == "" then
				return "/"
			end

			-- normalize slashes
			path = path:gsub("\\", "/")

			-- sshfs on Windows hosts may expose "/C:/path" (strip leading slash before drive)
			if path:match("^/%a:/") then
				path = path:sub(2)
			end

			-- leave ~ paths intact
			if path:sub(1, 1) == "~" then
				return path
			end

			-- Windows drive letter paths: "C:/foo" or "C:"
			if path:match("^%a:[/]?") then
				return path
			end

			-- ensure POSIX-style paths start with "/"
			if path:sub(1, 1) ~= "/" then
				return "/" .. path
			end

			return path
		end

		local function strip_trailing_slash(path)
			if not path or path == "/" then
				return path or "/"
			end
			return path:gsub("/+$", "")
		end

		-- Helper: compute local root that matches a mount (works even when mounting subdirs like /test)
		local function resolve_local_root(host_label, remote_root)
			remote_root = normalize_remote_root(remote_root)

			-- Try to read mount metadata from sshfs.nvim (preferred: handles /test-only mounts)
			local ok_mp, mount_point = pcall(require, "sshfs.lib.mount_point")
			if ok_mp then
				for _, m in ipairs(mount_point.list_active()) do
					if m.host == host_label then
						local mount_remote = normalize_remote_root(m.remote_path)
						mount_remote = strip_trailing_slash(mount_remote)
						local normalized_remote = strip_trailing_slash(remote_root)
						if normalized_remote:find(mount_remote, 1, true) == 1 then
							if mount_remote == "/" then
								return m.mount_path .. normalized_remote
							end
							local suffix = normalized_remote:sub(#mount_remote + 1)
							if suffix == "" then
								return m.mount_path
							end
							return m.mount_path .. suffix
						end
					end
				end
			end

			-- Fallback: assume mount root is "/" and mirror remote_root under ~/.sshfs/<host>
			local base = vim.fn.expand("~/.sshfs")
			return base .. "/" .. host_label .. remote_root
		end

		-- Command: prompt for host label + remote root (port optional) and attach
		vim.api.nvim_create_user_command("DapAttachRemoteRoot", function(opts)
			local args = {}
			for w in string.gmatch(opts.args or "", "%S+") do
				table.insert(args, w)
			end

			local host_label = args[1] or vim.fn.input("Host label (~/.sshfs/<label>): ")
			local remote_root = args[2] or vim.fn.input("Remote root (e.g. /test/t6i): ", "/test/t6i")
			remote_root = strip_trailing_slash(normalize_remote_root(remote_root))
			local port = tonumber(args[3] or "5679")

			local local_root = resolve_local_root(host_label, remote_root)
			if vim.fn.isdirectory(local_root) == 0 then
				vim.notify(
					"Mount not found: " .. local_root .. "\nRun :SSHConnect and mount first.",
					vim.log.levels.WARN
				)
				return
			end

			dap.run({
				type = "debugpy-remote",
				request = "attach",
				name = ("Attach 127.0.0.1:%d → %s"):format(port, remote_root),
				connect = { host = "127.0.0.1", port = port },
				pathMappings = { { localRoot = local_root, remoteRoot = remote_root } },
				justMyCode = false,
			})
		end, { nargs = "*" })

		-- Tiny helpers to start/stop a local SSH tunnel in the background (optional)
		local RDBG = { ssh_job = nil }
		local function start_tunnel(ssh_target, port)
			port = tonumber(port) or 5679
			if RDBG.ssh_job then
				return vim.notify("Tunnel already running", vim.log.levels.WARN)
			end
			RDBG.ssh_job = vim.fn.jobstart(
				{ "ssh", "-N", "-L", string.format("%d:127.0.0.1:%d", port, port), ssh_target },
				{
					on_exit = function()
						RDBG.ssh_job = nil
					end,
				}
			)
			if RDBG.ssh_job > 0 then
				vim.notify(("SSH tunnel :%d → %s"):format(port, ssh_target), vim.log.levels.INFO)
			else
				RDBG.ssh_job = nil
				vim.notify("Failed to start tunnel", vim.log.levels.ERROR)
			end
		end
		local function stop_tunnel()
			if not RDBG.ssh_job then
				return vim.notify("No tunnel to stop", vim.log.levels.WARN)
			end
			vim.fn.jobstop(RDBG.ssh_job)
			RDBG.ssh_job = nil
			vim.notify("SSH tunnel stopped", vim.log.levels.INFO)
		end

		vim.api.nvim_create_user_command("RDbgTunnelStart", function(opts)
			local a = {}
			for w in string.gmatch(opts.args or "", "%S+") do
				table.insert(a, w)
			end
			local target = a[1] or vim.fn.input("ssh target (user@host): ")
			local port = a[2] or "5679"
			start_tunnel(target, port)
		end, { nargs = "*" })

		vim.api.nvim_create_user_command("RDbgTunnelStop", function()
			stop_tunnel()
		end, {})

		-- Install golang specific config
		-- require('dap-go').setup()
		require("dap-python").setup()
	end,
}
