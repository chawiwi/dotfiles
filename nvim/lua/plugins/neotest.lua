vim.pack.add({
	{ src = "https://github.com/nvim-neotest/neotest" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
	{ src = "https://github.com/nvim-neotest/neotest-python" },
})

local function python_for_project(root)
	local starts = { root, vim.api.nvim_buf_get_name(0), vim.fn.getcwd() }
	for _, start in ipairs(starts) do
		if type(start) == "string" and start ~= "" then
			local directory = vim.fn.fnamemodify(start, ":p:h")
			for parent in vim.fs.parents(directory) do
				for _, venv in ipairs({ ".venv", "venv" }) do
					local python = vim.fs.joinpath(parent, venv, "bin", "python")
					if vim.fn.executable(python) == 1 then
						return python
					end
				end
			end
		end
	end
	return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
end

local neotest = require("neotest")
neotest.setup({
	adapters = {
		require("neotest-python")({
			runner = "pytest",
			python = python_for_project,
			dap = { justMyCode = false },
		}),
	},
	output = { open_on_run = "short" },
	quickfix = { enabled = true, open = false },
	summary = { follow = true },
})

local map = vim.keymap.set
map("n", "<leader>tn", function()
	neotest.run.run()
end, { desc = "Test nearest" })
map("n", "<leader>tF", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Test file" })
map("n", "<leader>ta", function()
	neotest.run.run(vim.fn.getcwd())
end, { desc = "Test all" })
map("n", "<leader>tl", neotest.run.run_last, { desc = "Test last" })
map("n", "<leader>td", function()
	neotest.run.run({ strategy = "dap" })
end, { desc = "Test debug nearest" })
map("n", "<leader>tS", neotest.run.stop, { desc = "Test stop" })
map("n", "<leader>ts", neotest.summary.toggle, { desc = "Test summary" })
map("n", "<leader>to", function()
	neotest.output.open({ enter = true, auto_close = true })
end, { desc = "Test output" })
map("n", "<leader>tO", neotest.output_panel.toggle, { desc = "Test output panel" })
