local M = {}

vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.nvim", version = "stable" },
	{ src = "https://github.com/adriankarlen/plugin-view.nvim" },
})

require("mini.icons").setup()
require("mini.ai").setup({ n_lines = 500 })
require("mini.align").setup()
require("mini.comment").setup()
require("mini.splitjoin").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.cmdline").setup()
require("mini.notify").setup()
require("mini.cursorword").setup()
require("mini.indentscope").setup({
	draw = { animation = require("mini.indentscope").gen_animation.none() },
})
require("mini.diff").setup({
	view = { style = "sign", signs = { add = "+", change = "~", delete = "_" } },
})
require("mini.pick").setup()
require("mini.statusline").setup({ use_icons = true })

require("plugin-view").setup()

function M.pick_files(cwd)
	MiniPick.builtin.files({}, { source = { cwd = cwd } })
end

function M.pick_recent_files()
	return MiniPick.registry.recent_files()
end

vim.ui.select = MiniPick.ui_select

MiniPick.registry.recent_files = function()
	local oldfiles = vim.tbl_filter(function(path)
		return vim.fn.filereadable(path) == 1
	end, vim.v.oldfiles)

	MiniPick.start({
		source = {
			items = oldfiles,
			name = "Recent files",
			choose = function(path)
				vim.api.nvim_win_call(MiniPick.get_picker_state().windows.target, function()
					vim.cmd("edit " .. vim.fn.fnameescape(path))
				end)
			end,
		},
	})
end

-- Make `:Pick files` accept `cwd`
MiniPick.registry.files = function(local_opts)
	local opts = { source = { cwd = local_opts.cwd } }
	local_opts.cwd = nil
	return MiniPick.builtin.files(local_opts, opts)
end

return M
