vim.pack.add({
	{ src = "https://github.com/folke/sidekick.nvim" },
})

require("sidekick").setup({
	-- This setup uses Sidekick as a Codex/context terminal. Keep NES opt-in so
	-- Copilot LSP is not required for the normal AI workflow.
	nes = { enabled = false },
	cli = {
		win = {
			layout = "right",
			split = { width = 50, height = 20 },
		},
		tools = {
			codex = {
				cmd = { "codex", "--approve-for-me" },
			},
		},
	},
	copilot = { status = { enabled = false } },
})

local scli = require("sidekick.cli")
local map = vim.keymap.set

local function picker_item_context(item, cwd)
	if type(item) == "string" then
		local path = vim.fs.isabs(item) and item or vim.fs.joinpath(cwd, item)
		return vim.fn.fnamemodify(path, ":p:~")
	end
	if type(item) == "table" then
		local path = item.path or item.file
		if path then
			path = vim.fs.isabs(path) and path or vim.fs.joinpath(cwd, path)
			local line = item.pos or item.lnum or item.line
			local col = item.col
			local location = vim.fn.fnamemodify(path, ":p:~")
			if line then
				location = location .. ":" .. line
				if col then
					location = location .. ":" .. col
				end
			end
			return location
		end
		return item.text
	end
	return tostring(item)
end

-- Send the focused MiniPick item, or marked items, as Sidekick context.
local function send_minipick_to_sidekick()
	local matches = MiniPick.get_picker_matches()
	if not matches or not matches.current then
		return
	end
	local picker = MiniPick.get_picker_opts()
	local cwd = (picker.source and picker.source.cwd) or vim.fn.getcwd()
	local items = #matches.marked > 0 and matches.marked or { matches.current }
	local contexts = vim.tbl_map(function(item)
		return picker_item_context(item, cwd)
	end, items)
	MiniPick.stop()
	vim.schedule(function()
		scli.send({ msg = table.concat(contexts, "\n") })
	end)
	return true
end

local pick_config = require("mini.pick").config
pick_config.mappings.sidekick_send = { char = "<M-o>", func = send_minipick_to_sidekick }
