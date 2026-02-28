-- Plugin: toppair/peek.nvim
-- Installed via store.nvim

return {
	{
		"toppair/peek.nvim",
		event = { "VeryLazy" },
		build = function()
			if vim.fn.executable("deno") ~= 1 then
				return
			end
			vim.fn.system({ "deno", "task", "--quiet", "build:fast" })
		end,
		config = function()
			local peek = require("peek")
			peek.setup({
				app = (vim.fn.executable("firefox") == 1) and { "firefox", "--new-window" } or "browser",
			})

			local function ensure_peek_bundle()
				local data_dir = vim.fn.stdpath("data")
				local plugin_dir = data_dir .. "/lazy/peek.nvim"
				local bundle_path = plugin_dir .. "/public/main.bundle.js"

				if vim.fn.filereadable(bundle_path) == 1 then
					return true
				end

				if vim.fn.executable("deno") ~= 1 then
					return false, "`deno` is not executable in PATH."
				end

				vim.notify("peek.nvim bundle missing, building with deno...", vim.log.levels.WARN)
				local cmd = "cd " .. vim.fn.shellescape(plugin_dir) .. " && deno task --quiet build:fast"
				local output = vim.fn.system({ "sh", "-c", cmd })
				if vim.v.shell_error ~= 0 then
					return false, "peek.nvim build failed:\n" .. output
				end

				if vim.fn.filereadable(bundle_path) ~= 1 then
					return false, "peek.nvim build finished, but public/main.bundle.js is still missing."
				end

				return true
			end

			vim.api.nvim_create_user_command("PeekOpen", function(opts)
				if vim.fn.executable("deno") ~= 1 then
					vim.notify("`deno` is not executable in PATH. Install deno to use peek.nvim.", vim.log.levels.ERROR)
					return
				end

				local ok, err = ensure_peek_bundle()
				if not ok then
					vim.notify(err, vim.log.levels.ERROR)
					return
				end

				peek.open(opts)
			end, {})

			vim.api.nvim_create_user_command("PeekClose", function()
				pcall(peek.close)
			end, {})

			local peek_cleanup = vim.api.nvim_create_augroup("PeekCleanup", { clear = true })
			vim.api.nvim_create_autocmd("VimLeavePre", {
				group = peek_cleanup,
				callback = function()
					pcall(vim.cmd, "silent! PeekClose")
				end,
			})
		end,
	},
}
