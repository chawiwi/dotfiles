return {
	{
		"kiyoon/jupynium.nvim",
		ft = { "python", "markdown" },
		-- Ensure geckodriver finds the real Firefox binary (snap installs a stub at /usr/bin/firefox)
		init = function()
			vim.env.MOZ_FIREFOX_PATH = "/snap/firefox/current/usr/lib/firefox/firefox"
			vim.env.PATH = vim.env.HOME .. "/.local/bin:" .. vim.env.PATH
		end,
		-- Keep the python side of the plugin in sync with the checked-out version.
		-- Uses the same python that Neovim is currently using.
		build = function()
			local py = vim.fn.exepath("python3")
			if py == "" then
				return
			end
			vim.fn.system({ py, "-m", "pip", "install", "--upgrade", "." })
		end,
		dependencies = { "rcarriga/nvim-notify", "stevearc/dressing.nvim" },
		opts = {
			use_default_keymaps = false, -- keep keymaps defined in plugins/keymaps.lua
			auto_attach_to_server = { enable = true },
			auto_start_server = { enable = true, file_pattern = { "*.ju.*" } },
			-- Snap Firefox keeps profiles in a different place; make Jupynium reuse your default profile.
			firefox_profiles_ini_path = vim.fn.expand("~/snap/firefox/common/.mozilla/firefox/profiles.ini"),
			firefox_profile_name = nil, -- use default profile
			-- Use the project venv Jupyter so nbclassic is available when auto-starting.
			jupyter_command = vim.fn.expand("~/git_files/personal_mess/.venv/bin/jupyter"),
			-- Force PATH/Firefox for the Python side (geckodriver inherits this)
			python_command = {
				"env",
				"PATH=" .. vim.env.HOME .. "/.local/bin:" .. vim.env.PATH,
				"MOZ_FIREFOX_PATH=/snap/firefox/current/usr/lib/firefox/firefox",
				-- use your project venv python so Selenium matches installed deps
				vim.fn.expand("~/git_files/personal_mess/.venv/bin/python"),
			},
			server = {
				log_level = "DEBUG", -- helps debug "rpc channel closed"
				log_file = vim.fn.stdpath("cache") .. "/jupynium.log",
				-- Jupynium only supports Firefox via Selenium; chromium will not work.
				use_browser = "firefox",
				headless = false, -- keep visible for easier debugging; toggle to true once stable
				-- Notebook 7 is unsupported; stick to the classic UI served at /nbclassic
				default_notebook_URL = "localhost:8888/nbclassic",
			},
		},
		config = function(_, opts)
			require("jupynium").setup(opts)

			local function stop_jupyter_server(opts_)
				opts_ = opts_ or {}
				local port = opts.server.default_notebook_URL:match(":(%d+)")
				port = port or "8888"

				local base = opts.jupyter_command
				if type(base) == "string" then
					base = { base }
				elseif type(base) == "table" then
					base = vim.deepcopy(base)
				else
					if not opts_.silent then
						vim.notify("Invalid jupyter_command; cannot stop server", vim.log.levels.WARN)
					end
					return
				end

				if vim.fn.executable(base[1]) ~= 1 then
					if not opts_.silent then
						vim.notify("Jupyter command not found: " .. base[1], vim.log.levels.WARN)
					end
					return
				end

				local function run_with(subcmd)
					local cmd = vim.list_extend(vim.deepcopy(base), subcmd)
					local output = vim.fn.system(cmd)
					return vim.v.shell_error, vim.fn.trim(output)
				end

				local code, output = run_with({ "notebook", "stop", port })
				if code ~= 0 then
					code, output = run_with({ "server", "stop", port })
				end

				if not opts_.silent then
					if code == 0 then
						vim.notify("Stopped Jupyter server on port " .. port, vim.log.levels.INFO)
					else
						vim.notify("Jupyter server stop failed: " .. output, vim.log.levels.WARN)
					end
				end
			end

			vim.api.nvim_create_user_command("JupyniumStopJupyterServer", function()
				stop_jupyter_server()
			end, { desc = "Stop Jupyter server started for Jupynium", force = true })

			local cleanup_group = vim.api.nvim_create_augroup("JupyniumJupyterCleanup", { clear = true })
			vim.api.nvim_create_autocmd("VimLeavePre", {
				group = cleanup_group,
				desc = "Stop Jupyter server on exit",
				callback = function()
					stop_jupyter_server({ silent = true })
				end,
			})

			-- Auto-convert opened .ipynb into a sibling .ju.py via jupytext (uses project venv)
			vim.api.nvim_create_autocmd("BufReadPost", {
				pattern = "*.ipynb",
				callback = function(a)
					local ipynb = vim.api.nvim_buf_get_name(a.buf)
					local ju = ipynb:gsub("%.ipynb$", ".ju.py")
					if ipynb == ju or vim.fn.filereadable(ju) == 1 then
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
					local ok = vim.fn.system({ jupytext, "--to", "py:percent", "--output", ju, ipynb })
					if vim.v.shell_error ~= 0 then
						vim.notify("jupytext failed: " .. ok, vim.log.levels.ERROR)
						return
					end
					vim.cmd("edit " .. ju)
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
