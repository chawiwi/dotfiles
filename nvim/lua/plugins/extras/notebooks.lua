return {
	{
		"ryan-ressmeyer/quench.nvim",
		ft = { "python" },
		build = ":UpdateRemotePlugins",
		init = function()
			local function revert_quench_frontend_css_for_lazy()
				local data = vim.fn.stdpath("data")
				local root = data .. "/lazy/quench.nvim"
				local index = root .. "/rplugin/python3/quench/frontend/index.html"
				if vim.fn.filereadable(index) ~= 1 or vim.fn.executable("git") ~= 1 then
					return
				end
				local html = table.concat(vim.fn.readfile(index), "\n")
				if not html:find("quench%-user%-style") then
					return
				end
				vim.fn.system({
					"git",
					"-C",
					root,
					"checkout",
					"--",
					"rplugin/python3/quench/frontend/index.html",
				})
			end

			local group = vim.api.nvim_create_augroup("quench_frontend_css_patch_lazy_pre", { clear = true })
			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = { "LazySyncPre", "LazyUpdatePre", "LazyInstallPre", "LazyCheckPre" },
				callback = revert_quench_frontend_css_for_lazy,
			})
		end,
		config = function()
			vim.g.quench_nvim_web_server_host = "127.0.0.1"
			vim.g.quench_nvim_web_server_port = 8765
			vim.g.quench_nvim_autostart_server = true

			-- Darken HTML outputs (tables/iframes) in Quench frontend.
			local function quench_frontend_paths()
				local data = vim.fn.stdpath("data")
				local root = data .. "/lazy/quench.nvim"
				local index = root .. "/rplugin/python3/quench/frontend/index.html"
				return root, index
			end

			local function patch_quench_frontend_css()
				local _, index = quench_frontend_paths()
				if vim.fn.filereadable(index) ~= 1 then
					return
				end
				local lines = vim.fn.readfile(index)
				local html = table.concat(lines, "\n")
				if html:find("quench%-user%-style") then
					return
				end
				local inject = [[

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
				local replaced, n = html:gsub("</style>", inject .. "\n</style>", 1)
				if n == 1 then
					vim.fn.writefile(vim.split(replaced, "\n", { plain = true }), index)
				end
			end

			local function revert_quench_frontend_css()
				local root, index = quench_frontend_paths()
				if vim.fn.filereadable(index) ~= 1 or vim.fn.executable("git") ~= 1 then
					return
				end
				local html = table.concat(vim.fn.readfile(index), "\n")
				if not html:find("quench%-user%-style") then
					return
				end
				vim.fn.system({
					"git",
					"-C",
					root,
					"checkout",
					"--",
					"rplugin/python3/quench/frontend/index.html",
				})
			end

			local group = vim.api.nvim_create_augroup("quench_frontend_css_patch", { clear = true })
			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = { "LazySyncPre", "LazyUpdatePre", "LazyInstallPre", "LazyCheckPre" },
				callback = revert_quench_frontend_css,
			})
			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = { "LazySync", "LazyUpdate", "LazyInstall", "LazyCheck" },
				callback = function()
					vim.schedule(patch_quench_frontend_css)
				end,
			})
			vim.api.nvim_create_autocmd("VimLeavePre", {
				group = group,
				callback = revert_quench_frontend_css,
			})

			patch_quench_frontend_css()

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
