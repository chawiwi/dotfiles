vim.pack.add({
	{ src = "https://github.com/uhs-robert/sshfs.nvim" },
})

local ssh_config = require("sshfs.lib.ssh_config")

require("sshfs").setup({
	connections = {
		ssh_configs = ssh_config.get_default_files(),
		sshfs_options = {
			reconnect = true,
			ConnectTimeout = 30,
			ConnectionAttempts = 3,
			compression = "yes",
			ServerAliveInterval = 15,
			ServerAliveCountMax = 3,
		},
	},
	mounts = { base_dir = vim.fn.expand("~/.sshfs") },
	hooks = {
		on_exit = { auto_unmount = true, clean_mount_folders = true },
		on_mount = { auto_run = "find" },
	},
	ui = { local_picker = { preferred_picker = "mini", fallback_to_netrw = true } },
})

local map = vim.keymap.set
map("n", "<leader>rm", "<CMD>SSHConnect<CR>", { desc = "Remote mount" })
map("n", "<leader>ro", "<CMD>SSHFiles<CR>", { desc = "Remote files" })
map("n", "<leader>rg", "<CMD>SSHGrep<CR>", { desc = "Remote grep" })
map("n", "<leader>ru", "<CMD>SSHDisconnect<CR>", { desc = "Remote unmount" })
