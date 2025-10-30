-- lua/plugins/sshfs.lua (or wherever you keep plugin specs)
return {
	"uhs-robert/sshfs.nvim",
	-- No dependencies required; it auto-detects your picker (Snacks, etc.)
	-- Neovim >= 0.10 recommended by the plugin
	opts = function()
		local cfg = require("sshfs.core.config")
		return {
			-- Connections / sshfs args (good defaults for resilience)
			connections = {
				ssh_configs = cfg.get_default_ssh_configs(),
				sshfs_args = {
					"-o reconnect",
					"-o ConnectTimeout=5",
					"-o compression=yes",
					"-o ServerAliveInterval=15",
					"-o ServerAliveCountMax=3",
					-- You can add: "-o cache=no", "-o follow_symlinks", "-o idmap=user", "-o umask=022" if desired
				},
			},
			-- Mount paths & cleanup policy
			mounts = {
				base_dir = vim.fn.expand("$HOME") .. "/.sshfs", -- our chosen base so DAP mapping is predictable
				unmount_on_exit = true, -- auto cleanup on :q / exit
			},
			handlers = {
				on_disconnect = {
					clean_mount_folders = true, -- remove empty dirs after unmount
				},
			},
			ui = {
				file_picker = {
					preferred_picker = "snacks", --auto works too
					auto_open_on_mount = true,
					fallback_to_netrw = true,
				},
			},
		}
	end,
}
