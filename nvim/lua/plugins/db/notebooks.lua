return {
	{
		"ryan-ressmeyer/quench.nvim",
		ft = { "python" },
		build = ":UpdateRemotePlugins",
		config = function()
			require("quench").setup({
				web_server = {
					host = "127.0.0.1",
					port = 8765,
					autostart_server = true,
				},
			})

			vim.g.quench_nvim_plugin_root = vim.fn.stdpath("data") .. "/lazy/quench.nvim"
			vim.g.quench_nvim_custom_css = [[
/* quench-user-style */
.output-html {
	background-color: #0f131a !important;
	color: #e6edf3 !important;
	border: 1px solid #30363d !important;
}
.output-html table {
	border-collapse: collapse !important;
	background: transparent !important;
	color: inherit !important;
}
.output-html th,
.output-html td {
	background: transparent !important;
	color: inherit !important;
	border-color: #30363d !important;
}
.output-html thead th {
	background: #1f2430 !important;
}
.output-html tbody tr:nth-child(even) {
	background: #141a22 !important;
}
.output-html-iframe {
	background: #0f131a !important;
}
]]

			local patch = vim.fn.stdpath("config") .. "/python/quench_runtime_patch.py"
			if vim.fn.has("python3") == 1 and vim.fn.filereadable(patch) == 1 then
				vim.cmd("py3file " .. vim.fn.fnameescape(patch))
			end

			-- Auto-convert opened .ipynb into a sibling .py (percent format) via jupytext (uses project venv)
			vim.api.nvim_create_autocmd("BufReadPost", {
				pattern = "*.ipynb",
				callback = function(a)
					local ipynb = vim.api.nvim_buf_get_name(a.buf)
					local py = ipynb:gsub("%.ipynb$", ".py")
					if ipynb == py or vim.fn.filereadable(py) == 1 then
						return
					end
					local jupytext = vim.fn.expand("~/git_files/personal_mess/.venv/bin/jupytext")
					if vim.fn.executable(jupytext) ~= 1 then
						vim.notify(
							"jupytext not installed in project venv; run: pip install jupytext",
							vim.log.levels.WARN
						)
						return
					end
					local ok = vim.fn.system({ jupytext, "--to", "py:percent", "--output", py, ipynb })
					if vim.v.shell_error ~= 0 then
						vim.notify("jupytext failed: " .. ok, vim.log.levels.ERROR)
						return
					end
					vim.cmd("edit " .. py)
				end,
			})
		end,
	},
	{
		"stellarjmr/notebook_style.nvim",
		ft = { "python", "markdown" },
		opts = {
			render_markdown = true,
		},
	},
}
