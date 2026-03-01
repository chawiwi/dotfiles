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
			local function resolve_python()
				if type(vim.g.python3_host_prog) == "string" and vim.g.python3_host_prog ~= "" then
					if vim.fn.executable(vim.g.python3_host_prog) == 1 then
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
