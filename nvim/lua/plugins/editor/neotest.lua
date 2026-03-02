-- Plugin: nvim-neotest/neotest
-- Installed via store.nvim

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-python",
		},
		opts = function()
			local uv = vim.uv or vim.loop
			local is_windows = uv.os_uname().sysname:match("Windows") ~= nil

			local function is_executable(path)
				return type(path) == "string" and path ~= "" and vim.fn.executable(path) == 1
			end

			local function find_nearest_venv_python(start_path)
				if type(start_path) ~= "string" or start_path == "" then
					return nil
				end

				local dir = vim.fs.normalize(start_path)
				local stat = uv.fs_stat(dir)
				if stat and stat.type == "file" then
					dir = vim.fs.dirname(dir)
				end

				local python_bins = is_windows and {
					{ "Scripts", "python.exe" },
					{ "Scripts", "python" },
				} or {
					{ "bin", "python" },
					{ "bin", "python3" },
				}

				while dir and dir ~= "" do
					for _, venv_name in ipairs({ ".venv", "venv" }) do
						local venv_dir = vim.fs.joinpath(dir, venv_name)
						local venv_stat = uv.fs_stat(venv_dir)
						if venv_stat and venv_stat.type == "directory" then
							for _, parts in ipairs(python_bins) do
								local python_path = vim.fs.joinpath(venv_dir, parts[1], parts[2])
								if is_executable(python_path) then
									return python_path
								end
							end
						end
					end

					local parent = vim.fs.dirname(dir)
					if not parent or parent == dir then
						break
					end
					dir = parent
				end

				return nil
			end

			local function resolve_python(root)
				local starts = {}
				local seen = {}

				local function add_start(path)
					if type(path) ~= "string" or path == "" then
						return
					end
					local normalized = vim.fs.normalize(path)
					if not seen[normalized] then
						seen[normalized] = true
						table.insert(starts, normalized)
					end
				end

				add_start(root)
				add_start(vim.api.nvim_buf_get_name(0))
				add_start(vim.fn.getcwd())

				for _, start in ipairs(starts) do
					local python_path = find_nearest_venv_python(start)
					if python_path then
						return python_path
					end
				end

				if type(vim.g.python3_host_prog) == "string" and vim.g.python3_host_prog ~= "" then
					if is_executable(vim.g.python3_host_prog) then
						return vim.g.python3_host_prog
					end
				end

				local python3 = vim.fn.exepath("python3")
				if python3 ~= "" then
					return python3
				end

				local python = vim.fn.exepath("python")
				if python ~= "" then
					return python
				end

				return "python3"
			end

			return {
				adapters = {
					require("neotest-python")({
						runner = "pytest",
						python = resolve_python,
						dap = { justMyCode = false },
					}),
				},
				output = {
					open_on_run = "short",
				},
				quickfix = {
					enabled = true,
					open = false,
				},
				summary = {
					follow = true,
				},
			}
		end,
		config = function(_, opts)
			require("neotest").setup(opts)
		end,
	},
}
