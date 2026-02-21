-- lua/plugins/sshfs.lua (or wherever you keep plugin specs)
return {
    "uhs-robert/sshfs.nvim",
    -- No dependencies required; it auto-detects your picker (Snacks, etc.)
    -- Neovim >= 0.10 recommended by the plugin
	opts = function()
		local ssh_config = require("sshfs.lib.ssh_config")
		return {
			connections = {
				ssh_configs = ssh_config.get_default_files(),
				sshfs_options = {
					reconnect = true,
					-- Slow VPN/SSO boxes need a longer window to finish handshakes
					ConnectTimeout = 30,
					ConnectionAttempts = 3,
					compression = "yes",
					ServerAliveInterval = 15,
					ServerAliveCountMax = 3,
				},
			},
			mounts = {
				base_dir = vim.fn.expand("$HOME") .. "/.sshfs", -- keep in sync with debug.lua
			},
			hooks = {
				on_exit = {
					auto_unmount = true,
					clean_mount_folders = true,
				},
				on_mount = {
					auto_run = "find",
				},
			},
			ui = {
				local_picker = {
					preferred_picker = "snacks",
					fallback_to_netrw = true,
				},
			},
		}
	end,
	config = function(_, opts)
		-- Keep the default setup then patch sshfs.nvim to reuse the authenticated ControlMaster
		require("sshfs").setup(opts)

		local Config = require("sshfs.config")
		local ssh = require("sshfs.lib.ssh")
		local original_build_cmd = ssh.build_command_string

		-- Reuse the ControlMaster socket (needed for password-only hosts) instead of reauthing
		local function socket_opts()
			return Config.get_control_master_options()
		end

		ssh.build_command_string = function(auth_type)
			if auth_type ~= "socket" then
				return original_build_cmd(auth_type)
			end

			local cmd_parts = { "ssh" }
			for _, opt in ipairs(socket_opts()) do
				table.insert(cmd_parts, "-o")
				table.insert(cmd_parts, opt)
			end
			return table.concat(cmd_parts, " ")
		end

		-- Also reuse the control socket when resolving "~" paths
		ssh.get_remote_home = function(host, callback)
			local cmd = { "ssh" }
			for _, opt in ipairs(socket_opts()) do
				table.insert(cmd, "-o")
				table.insert(cmd, opt)
			end

			table.insert(cmd, host)
			table.insert(cmd, "readlink -f $HOME 2>/dev/null || echo $HOME")

			vim.system(cmd, { text = true }, function(obj)
				vim.schedule(function()
					if obj.code == 0 then
						local home_path = vim.trim(obj.stdout or "")
						if home_path ~= "" and home_path:sub(1, 1) == "/" then
							callback(home_path, nil)
						else
							callback(nil, "Remote $HOME output invalid: '" .. home_path .. "'")
						end
					else
						local error_msg = vim.trim(obj.stderr or obj.stdout or "Unknown error")
						callback(nil, error_msg)
					end
				end)
			end)
		end

		-- Fallback: if ControlMaster reuse fails, retry with an interactive sshfs mount
		local function build_sshfs_opts_no_socket()
			local cfg = Config.get()
			local options = {}
			local sshfs_opts = (cfg.connections and cfg.connections.sshfs_options) or {}
			for key, value in pairs(sshfs_opts) do
				if value == true then
					table.insert(options, key)
				elseif value ~= false and value ~= nil then
					table.insert(options, string.format("%s=%s", key, tostring(value)))
				end
			end
			-- Drop any ssh_command override so we get a fresh, promptable ssh
			for i = #options, 1, -1 do
				if options[i]:match("^ssh_command=") then
					table.remove(options, i)
				end
			end
			return options
		end

		local function interactive_sshfs_fallback(host, mount_point, remote_path_suffix, callback)
			remote_path_suffix = remote_path_suffix or (host.path or "/")

			local options = build_sshfs_opts_no_socket()
			local remote_path = host.name
			if host.user then
				remote_path = host.user .. "@" .. remote_path
			end
			remote_path = remote_path .. ":" .. remote_path_suffix

			local cmd = { "sshfs", remote_path, mount_point, "-o", table.concat(options, ",") }
			if host.port then
				table.insert(cmd, "-p")
				table.insert(cmd, host.port)
			end

			local buf = vim.api.nvim_create_buf(false, true)
			vim.bo[buf].bufhidden = "wipe"
			local width = math.floor(vim.o.columns * 0.9)
			local height = math.floor(vim.o.lines * 0.5)
			local row = math.floor((vim.o.lines - height) / 2)
			local col = math.floor((vim.o.columns - width) / 2)
			local win = vim.api.nvim_open_win(buf, true, {
				relative = "editor",
				width = width,
				height = height,
				row = row,
				col = col,
				style = "minimal",
				border = "rounded",
				title = " sshfs fallback: " .. host.name .. " ",
				title_pos = "center",
			})

			local job = vim.fn.jobstart(cmd, {
				term = true,
				on_exit = function(_, code, _)
					vim.schedule(function()
						local ok = code == 0
						if ok then
							vim.notify("sshfs fallback mounted " .. host.name, vim.log.levels.INFO)
							callback({
								success = true,
								message = "Mounted via interactive sshfs fallback",
								resolved_path = remote_path_suffix,
							})
						else
							vim.notify("sshfs fallback failed (exit " .. code .. ")", vim.log.levels.ERROR)
							callback({
								success = false,
								message = string.format("sshfs fallback failed (exit %d)", code),
							})
						end
						if ok and vim.api.nvim_win_is_valid(win) then
							vim.api.nvim_win_close(win, true)
						end
					end)
				end,
			})

			if job <= 0 then
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
				vim.notify("Failed to start sshfs fallback terminal", vim.log.levels.ERROR)
				callback({
					success = false,
					message = "Failed to start sshfs fallback terminal",
				})
				return
			end

			vim.cmd("startinsert")
		end

		local Sshfs = require("sshfs.lib.sshfs")
		local original_auth_mount = Sshfs.authenticate_and_mount

		Sshfs.authenticate_and_mount = function(host, mount_point, remote_path_suffix, callback)
			original_auth_mount(host, mount_point, remote_path_suffix, function(result)
				if result.success then
					callback(result)
					return
				end

				vim.notify(
					(result.message or "sshfs mount failed")
						.. ". Retrying with interactive sshfs fallback (password-friendly)...",
					vim.log.levels.WARN
				)

				interactive_sshfs_fallback(host, mount_point, remote_path_suffix, callback)
			end)
		end
	end,
}
