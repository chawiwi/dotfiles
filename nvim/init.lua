vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false

-- Global indentation settings
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.relativenumber = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- --- Python host + PATH (runs before lazy) ---------------------------
do
	local venv = vim.fn.expand("~/git_files/personal_mess/.venv")
	local bin = venv .. "/bin"

	local function prepend_path(dir)
		if dir ~= "" and vim.fn.isdirectory(dir) == 1 then
			local PATH = vim.env.PATH or ""
			if not string.find(":" .. PATH .. ":", ":" .. dir .. ":", 1, true) then
				vim.env.PATH = dir .. ":" .. PATH
			end
		end
	end

	-- Use the venv's python as Neovim's host if present
	local py = bin .. "/python3"
	if vim.fn.executable(py) == 1 then
		vim.g.python3_host_prog = py
	end

	-- Make sure jobs (jupytext, etc.) can be found
	prepend_path(bin) -- project venv
	prepend_path(vim.fn.expand("~/.local/bin")) -- pipx/global user bin (optional)

	-- Helpful warning if jupytext still isn't visible
	if vim.fn.executable("jupytext") ~= 1 then
		vim.schedule(function()
			vim.notify("jupytext not found in PATH (check venv or ~/.local/bin)", vim.log.levels.WARN)
		end)
	end
end

-- --- Curly-fence fixer: ```python -> ```{python} --------------------
do
	local allow = { python = true, r = true, julia = true, bash = true, sh = true }

	local function fix_fences(buf)
		buf = buf == 0 and vim.api.nvim_get_current_buf() or buf
		local ft = vim.bo[buf].filetype
		if ft ~= "markdown" and ft ~= "quarto" then
			return
		end

		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		local changed = false
		for i, s in ipairs(lines) do
			-- skip lines already using curly fences
			if not s:find("{", 1, true) then
				-- tolerate leading junk/spaces:   xxx ```python
				local ticks, lang, rest = s:match("^%s*([`~][`~][`~])%s*([%w_+%-]+)%s*(.*)$")
				if ticks and lang and allow[lang] and (rest == "" or rest:match("^%s*$")) then
					lines[i] = string.format("%s{%s}", ticks, lang)
					changed = true
				end
			end
		end
		if changed then
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		end
	end

	local grp = vim.api.nvim_create_augroup("CurlyFences", { clear = true })

	-- Run after filetype is set (works for .ipynb -> md buffers)
	vim.api.nvim_create_autocmd("FileType", {
		group = grp,
		pattern = { "markdown", "quarto" },
		callback = function(a)
			-- defer so it runs after jupytext/quarto finish populating the buffer
			vim.defer_fn(function()
				fix_fences(a.buf)
			end, 20)
		end,
	})

	-- Enforce on save for md/qmd files
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = grp,
		pattern = { "*.md", "*.qmd" },
		callback = function(a)
			fix_fences(a.buf)
		end,
	})

	-- Manual command if you ever want to run it yourself
	vim.api.nvim_create_user_command("FixFences", function()
		fix_fences(0)
	end, {})
end
-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true
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

-- Toggle for autoformat on save for buffer(FormatDisable!) or globally (FormatDisable)
vim.g.autoformat = true

vim.api.nvim_create_user_command("FormatDisable", function(args)
	if args.bang then
		vim.b.autoformat = false
	else
		vim.g.autoformat = false
	end
end, { bang = true })

vim.api.nvim_create_user_command("FormatEnable", function(args)
	if args.bang then
		vim.b.autoformat = true
	else
		vim.g.autoformat = true
	end
end, { bang = true })

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		require("plugins.colorscheme"),
		require("plugins.treesitter"),
		require("plugins.lsp"),
		require("plugins.snacks"),
		{ import = "plugins.ui" },
		{ import = "plugins.editor" },
		{ import = "plugins.extras" },
		require("plugins.keymaps"),
	},
	-- install = { colorscheme = { "habamax" } },
	{
		ui = {
			-- If you are using a Nerd Font: set icons to an empty table which will use the
			-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
			icons = vim.g.have_nerd_font and {} or {
				cmd = "⌘",
				config = "🛠",
				event = "📅",
				ft = "📂",
				init = "⚙",
				keys = "🗝",
				plugin = "🔌",
				runtime = "💻",
				require = "🌙",
				source = "📄",
				start = "🚀",
				task = "📌",
				lazy = "💤 ",
			},
		},
	},
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
