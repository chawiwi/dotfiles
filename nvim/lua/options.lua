vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Use real, four-column tabs by default. Keep these together because
-- filetype plugins may override any of them independently.
vim.opt.tabstop = 4
vim.opt.softtabstop = -1
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.preserveindent = true

-- YAML's grammar prohibits tabs for indentation, so it is the explicit
-- exception to the tab-first default.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "yaml",
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = -1
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
	end,
})

local function infer_space_width(indents)
	local current = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
	local best_width = current
	local best_score = -1
	local preference = { [current] = 3, [4] = 2, [2] = 1, [8] = 0 }

	for _, width in ipairs({ 2, 4, 8 }) do
		local score = 0
		for _, indent in ipairs(indents) do
			if indent >= width and indent % width == 0 then
				score = score + 1
			end
		end

		local best_preference = preference[best_width] or -1
		local width_preference = preference[width] or -1
		if score > best_score or (score == best_score and width_preference > best_preference) then
			best_width = width
			best_score = score
		end
	end

	return best_width
end

local function match_existing_indent()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].buftype ~= "" then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(vim.api.nvim_buf_line_count(bufnr), 256), false)
	local tab_lines = 0
	local space_indents = {}

	for _, line in ipairs(lines) do
		local indent = line:match("^([ \t]+)%S")
		if indent then
			if indent:find("\t", 1, true) then
				tab_lines = tab_lines + 1
			elseif #indent > 1 then
				space_indents[#space_indents + 1] = #indent
			end
		end
	end

	if #space_indents == 0 and tab_lines == 0 then
		return
	end

	if #space_indents >= tab_lines then
		local width = infer_space_width(space_indents)
		vim.bo[bufnr].expandtab = true
		vim.bo[bufnr].shiftwidth = width
		vim.bo[bufnr].softtabstop = width
	else
		vim.bo[bufnr].expandtab = false
		vim.bo[bufnr].shiftwidth = vim.bo[bufnr].tabstop
		vim.bo[bufnr].softtabstop = -1
	end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "FileType" }, {
	desc = "Match indentation settings to existing buffer indentation",
	group = vim.api.nvim_create_augroup("config-match-existing-indent", { clear = true }),
	callback = match_existing_indent,
})

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.g.have_nerd_font = true
-- Enable break indent
vim.o.breakindent = true
-- Configure how new splits should be opened
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- Preview substitutions live, as you type!
vim.o.inccommand = "split"
-- Show which line your cursor is on
vim.o.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10
-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
