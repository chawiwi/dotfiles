---------------------------------------------------------------------------
-- non-plugin keymaps
---------------------------------------------------------------------------
-- Press jk or kj in insert/term mode to return to normal mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("t", "jk", "<C-\\><C-n>", { desc = "Exit terminal insert" })
vim.keymap.set("t", "kj", "<C-\\><C-n>", { desc = "Exit terminal insert" })

-- Resizing windows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Resize Up" })
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Resize Up" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Resize Up" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Resize Up" })

-- Toggle for autoformat on save for buffer(FormatDisable!) or globally (FormatDisable)
vim.keymap.set("n", "<leader>tf", function()
	vim.b.autoformat = (vim.b.autoformat == false) and true or false
	print("Autoformat (buffer): " .. (vim.b.autoformat == false and "OFF" or "ON"))
end, { desc = "[T]oggle format-on-save (buffer)" })

---------------------------------------------------------------------------
-- plugin keymaps
---------------------------------------------------------------------------
return {
	---------------------------------------------------------------------------
	-- Snacks keymaps (merged with snacks.lua)
	---------------------------------------------------------------------------
	-- lua/plugins/keymaps.lua (Snacks section)
	{
		"folke/snacks.nvim",
		keys = function()
			local Snacks = require("snacks")
			local stdpath = vim.fn.stdpath

			return {
				-- Top pickers & explorer
				{
					"<leader><space>",
					function()
						Snacks.picker.smart()
					end,
					desc = "Smart Find Files",
				},
				{
					"<leader>,",
					function()
						Snacks.picker.buffers()
					end,
					desc = "Buffers",
				},
				{
					"<leader>/",
					function()
						Snacks.picker.grep()
					end,
					desc = "Grep",
				},
				{
					"<leader>:",
					function()
						Snacks.picker.command_history()
					end,
					desc = "Command History",
				},
				{
					"<leader>n",
					function()
						Snacks.picker.notifications()
					end,
					desc = "Notification History",
				},
				{
					"<leader>e",
					function()
						Snacks.explorer()
					end,
					desc = "File Explorer",
				},

				-- find
				{
					"<leader>fb",
					function()
						Snacks.picker.buffers()
					end,
					desc = "Buffers",
				},
				{
					"<leader>fc",
					function()
						Snacks.picker.files({ cwd = stdpath("config") })
					end,
					desc = "Find Config File",
				},
				{
					"<leader>ff",
					function()
						Snacks.picker.files()
					end,
					desc = "Find Files",
				},
				{
					"<leader>fg",
					function()
						Snacks.picker.git_files()
					end,
					desc = "Find Git Files",
				},
				{
					"<leader>fp",
					function()
						Snacks.picker.projects()
					end,
					desc = "Projects",
				},
				{
					"<leader>fr",
					function()
						Snacks.picker.recent()
					end,
					desc = "Recent",
				},

				-- git
				{
					"<leader>gb",
					function()
						Snacks.picker.git_branches()
					end,
					desc = "Git Branches",
				},
				{
					"<leader>gl",
					function()
						Snacks.picker.git_log()
					end,
					desc = "Git Log",
				},
				{
					"<leader>gL",
					function()
						Snacks.picker.git_log_line()
					end,
					desc = "Git Log Line",
				},
				{
					"<leader>gs",
					function()
						Snacks.picker.git_status()
					end,
					desc = "Git Status",
				},
				{
					"<leader>gS",
					function()
						Snacks.picker.git_stash()
					end,
					desc = "Git Stash",
				},
				{
					"<leader>gd",
					function()
						Snacks.picker.git_diff()
					end,
					desc = "Git Diff (Hunks)",
				},
				{
					"<leader>gf",
					function()
						Snacks.picker.git_log_file()
					end,
					desc = "Git Log File",
				},

				-- grep / search
				{
					"<leader>sb",
					function()
						Snacks.picker.lines()
					end,
					desc = "Buffer Lines",
				},
				{
					"<leader>sB",
					function()
						Snacks.picker.grep_buffers()
					end,
					desc = "Grep Open Buffers",
				},
				{
					"<leader>sg",
					function()
						Snacks.picker.grep()
					end,
					desc = "Grep",
				},
				{
					"<leader>sw",
					function()
						Snacks.picker.grep_word()
					end,
					desc = "Visual/Word",
					mode = { "n", "x" },
				},
				{
					'<leader>s"',
					function()
						Snacks.picker.registers()
					end,
					desc = "Registers",
				},
				{
					"<leader>s/",
					function()
						Snacks.picker.search_history()
					end,
					desc = "Search History",
				},
				{
					"<leader>sa",
					function()
						Snacks.picker.autocmds()
					end,
					desc = "Autocmds",
				},
				{
					"<leader>sc",
					function()
						Snacks.picker.command_history()
					end,
					desc = "Command History",
				},
				{
					"<leader>sC",
					function()
						Snacks.picker.commands()
					end,
					desc = "Commands",
				},
				{
					"<leader>sd",
					function()
						Snacks.picker.diagnostics()
					end,
					desc = "Diagnostics",
				},
				{
					"<leader>sD",
					function()
						Snacks.picker.diagnostics_buffer()
					end,
					desc = "Buffer Diagnostics",
				},
				{
					"<leader>sh",
					function()
						Snacks.picker.help()
					end,
					desc = "Help Pages",
				},
				{
					"<leader>sH",
					function()
						Snacks.picker.highlights()
					end,
					desc = "Highlights",
				},
				{
					"<leader>si",
					function()
						Snacks.picker.icons()
					end,
					desc = "Icons",
				},
				{
					"<leader>sj",
					function()
						Snacks.picker.jumps()
					end,
					desc = "Jumps",
				},
				{
					"<leader>sk",
					function()
						Snacks.picker.keymaps()
					end,
					desc = "Keymaps",
				},
				{
					"<leader>sl",
					function()
						Snacks.picker.loclist()
					end,
					desc = "Location List",
				},
				{
					"<leader>sm",
					function()
						Snacks.picker.marks()
					end,
					desc = "Marks",
				},
				{
					"<leader>sM",
					function()
						Snacks.picker.man()
					end,
					desc = "Man Pages",
				},
				{
					"<leader>sp",
					function()
						Snacks.picker.lazy()
					end,
					desc = "Search Plugin Spec",
				},
				{
					"<leader>sq",
					function()
						Snacks.picker.qflist()
					end,
					desc = "Quickfix List",
				},
				{
					"<leader>sR",
					function()
						Snacks.picker.resume()
					end,
					desc = "Resume",
				},
				{
					"<leader>su",
					function()
						Snacks.picker.undo()
					end,
					desc = "Undo History",
				},
				{
					"<leader>uC",
					function()
						Snacks.picker.colorschemes()
					end,
					desc = "Colorschemes",
				},

				-- LSP
				{
					"gd",
					function()
						Snacks.picker.lsp_definitions()
					end,
					desc = "Goto Definition",
				},
				{
					"gD",
					function()
						Snacks.picker.lsp_declarations()
					end,
					desc = "Goto Declaration",
				},
				{
					"gr",
					function()
						Snacks.picker.lsp_references()
					end,
					desc = "References",
					nowait = true,
				},
				{
					"gI",
					function()
						Snacks.picker.lsp_implementations()
					end,
					desc = "Goto Implementation",
				},
				{
					"gy",
					function()
						Snacks.picker.lsp_type_definitions()
					end,
					desc = "Goto Type Definition",
				},
				{
					"<leader>ss",
					function()
						Snacks.picker.lsp_symbols()
					end,
					desc = "LSP Symbols",
				},
				{
					"<leader>sS",
					function()
						Snacks.picker.lsp_workspace_symbols()
					end,
					desc = "LSP Workspace Symbols",
				},

				-- Other
				{
					"<leader>z",
					function()
						Snacks.zen()
					end,
					desc = "Toggle Zen Mode",
				},
				{
					"<leader>Z",
					function()
						Snacks.zen.zoom()
					end,
					desc = "Toggle Zoom",
				},
				{
					"<leader>.",
					function()
						Snacks.scratch()
					end,
					desc = "Toggle Scratch Buffer",
				},
				{
					"<leader>S",
					function()
						Snacks.scratch.select()
					end,
					desc = "Select Scratch Buffer",
				},
				{
					"<leader>bd",
					function()
						Snacks.bufdelete()
					end,
					desc = "Delete Buffer",
				},
				{
					"<leader>cR",
					function()
						Snacks.rename.rename_file()
					end,
					desc = "Rename File",
				},
				{
					"<leader>gw",
					function()
						Snacks.gitbrowse()
					end,
					desc = "Git WebBrowse",
					mode = { "n", "v" },
				},
				{
					"<leader>gg",
					function()
						Snacks.lazygit()
					end,
					desc = "Lazygit",
				},
				{
					"<leader>un",
					function()
						Snacks.notifier.hide()
					end,
					desc = "Dismiss All Notifications",
				},
				{
					"<c-/>",
					function()
						Snacks.terminal()
					end,
					desc = "Toggle Terminal",
				},
				{
					"<c-_>",
					function()
						Snacks.terminal()
					end,
					desc = "which_key_ignore",
				},
				{
					"]]",
					function()
						Snacks.words.jump(vim.v.count1)
					end,
					desc = "Next Reference",
					mode = { "n", "t" },
				},
				{
					"[[",
					function()
						Snacks.words.jump(-vim.v.count1)
					end,
					desc = "Prev Reference",
					mode = { "n", "t" },
				},
				{
					"<leader>N",
					function()
						Snacks.win({
							file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
							width = 0.6,
							height = 0.6,
							wo = {
								spell = false,
								wrap = false,
								signcolumn = "yes",
								statuscolumn = " ",
								conceallevel = 3,
							},
						})
					end,
					desc = "Neovim News",
				},
			}
		end,
	},
	-- vim-tmux-navigator
	{
		"christoomey/vim-tmux-navigator",
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},
	---------------------------------------------------------------------------
	-- debug keymaps
	---------------------------------------------------------------------------
	{
		"mfussenegger/nvim-dap",
		keys = function()
			local dap = require("dap")
			local dapview = require("dap-view")
			local widgets = require("dap.ui.widgets")

			return {
				{
					"<F5>",
					function()
						dap.continue()
					end,
					desc = "Debug: Start/Continue",
				},
				{
					"<F1>",
					function()
						dap.step_into()
					end,
					desc = "Debug: Step Into",
				},
				{
					"<F2>",
					function()
						dap.step_over()
					end,
					desc = "Debug: Step Over",
				},
				{
					"<F3>",
					function()
						dap.step_out()
					end,
					desc = "Debug: Step Out",
				},
				{
					"<F4>",
					function()
						dap.run_to_cursor()
					end,
					desc = "Debug: Run to Cursor",
				},
				{
					"<F8>",
					function()
						dap.reverse_continue()
					end,
					desc = "Debug: Reverse Continue",
				},
				{
					"<leader>b",
					function()
						dap.toggle_breakpoint()
					end,
					desc = "Debug: Toggle Breakpoint",
				},
				{
					"<leader>B",
					function()
						dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
					end,
					desc = "Debug: Set Breakpoint (cond.)",
				},
				{
					"<F7>",
					function()
						dapview.toggle()
					end,
					desc = "Debug: Toggle UI (dap-view)",
				},
				{
					"<F6>",
					function()
						if not pcall(dap.restart) then
							dap.terminate()
							vim.defer_fn(function()
								dap.run_last()
							end, 200)
						end
					end,
					desc = "Debug: Restart",
				},
				-- Debug attach helpers
				{ "<leader>ds", ":RDbgTunnelStart<CR>", desc = "Debug: Start SSH tunnel" },
				{ "<leader>dx", ":RDbgTunnelStop<CR>", desc = "Debug: Stop SSH tunnel" },
				{ "<leader>da", ":DapAttachRemoteRoot<CR>", desc = "Debug: Attach (prompt host/root)" },
				-- NEW: Add expression to Watches (cursor word or visual selection)
				{
					"<leader>dw",
					function()
						dapview.add_expr()
					end,
					desc = "Debug: Watch add (cursor/visual)",
				},
				{
					"<leader>dw",
					function()
						dapview.add_expr()
					end,
					mode = "v",
					desc = "Debug: Watch add (selection)",
				},

				-- Optional: prompt to add explicit watch
				{
					"<leader>dp",
					function()
						local expr = vim.fn.input("Watch expression: ")
						if expr ~= "" then
							dapview.add_expr(expr, true)
						end
					end,
					desc = "Debug: Watch add (prompt)",
				},

				-- NEW: Evaluate expression (hover-like; uses nvim-dap widgets)
				-- Normal mode → word under cursor; Visual mode → selection
				{
					"<leader>de",
					function()
						widgets.hover()
					end,
					desc = "Debug: Evaluate (hover)",
				},
				{
					"<leader>de",
					function()
						widgets.hover()
					end,
					mode = "v",
					desc = "Debug: Evaluate (hover selection)",
				},
			}
		end,
	},
	---------------------------------------------------------------------------
	-- sshfs keymaps
	---------------------------------------------------------------------------
	{
		"uhs-robert/sshfs.nvim",
		keys = function()
			return {
				{ "<leader>rm", ":SSHConnect<CR>", desc = "Remote: Mount (Snacks picker)" }, -- mounts + picks host
				{ "<leader>ro", ":SSHBrowse<CR>", desc = "Remote: Open picker in mount" }, -- auto uses Snacks if present
				{ "<leader>rg", ":SSHGrep<CR>", desc = "Remote: Grep in mount" }, -- Snacks grep if present
				{ "<leader>ru", ":SSHDisconnect<CR>", desc = "Remote: Unmount" },
			}
		end,
	},
	---------------------------------------------------------------------------
	-- gitsigns keymaps
	---------------------------------------------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		keys = function()
			local gitsigns = require("gitsigns")

			return {
				-- Navigation
				{
					"]c",
					function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end,
					desc = "Jump to next git [c]hange",
				},
				{
					"[c",
					function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end,
					desc = "Jump to previous git [c]hange",
				},

				-- Actions (visual mode)
				{
					"<leader>hs",
					function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end,
					mode = "v",
					desc = "git [s]tage hunk",
				},
				{
					"<leader>hr",
					function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end,
					mode = "v",
					desc = "git [r]eset hunk",
				},

				-- Actions (normal mode)
				{ "<leader>hs", gitsigns.stage_hunk, desc = "git [s]tage hunk" },
				{ "<leader>hr", gitsigns.reset_hunk, desc = "git [r]eset hunk" },
				{ "<leader>hS", gitsigns.stage_buffer, desc = "git [S]tage buffer" },
				{ "<leader>hu", gitsigns.undo_stage_hunk, desc = "git [u]ndo stage hunk" },
				{ "<leader>hR", gitsigns.reset_buffer, desc = "git [R]eset buffer" },
				--{ "<leader>hp", gitsigns.preview_hunk,        desc = "git [p]review hunk" },
				{ "<leader>hb", gitsigns.blame_line, desc = "git [b]lame line" },
				{ "<leader>hd", gitsigns.diffthis, desc = "git [d]iff against index" },
				{
					"<leader>hD",
					function()
						gitsigns.diffthis("@")
					end,
					desc = "git [D]iff against last commit",
				},

				-- Toggles
				{ "<leader>tb", gitsigns.toggle_current_line_blame, desc = "[T]oggle git show [b]lame line" },
				{ "<leader>tD", gitsigns.preview_hunk_inline, desc = "[T]oggle git show [D]eleted" },
			}
		end,
	},
	---------------------------------------------------------------------------
	-- diffview keymaps
	---------------------------------------------------------------------------
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff [v]iew" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File [h]istory" },
			{ "<leader>gB", "<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<cr>", desc = "[B]ranch changes" },
		},
	},
	---------------------------------------------------------------------------
	-- harpoon keymaps
	---------------------------------------------------------------------------
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		keys = function()
			local harpoon = require("harpoon")

			-- Snacks-powered Harpoon menu
			local normalize_list = function(t)
				local normalized = {}
				for _, v in pairs(t) do
					if v ~= nil then
						table.insert(normalized, v)
					end
				end
				return normalized
			end

			local function list()
				return harpoon:list()
			end

			vim.keymap.set("n", "<leader>hh", function()
				Snacks.picker({
					finder = function()
						local file_paths = {}
						local list = normalize_list(list().items)
						for i, item in ipairs(list) do
							table.insert(file_paths, { text = item.value, file = item.value })
						end
						return file_paths
					end,
					win = {
						input = {
							keys = { ["dd"] = { "harpoon_delete", mode = { "n", "x" } } },
						},
						list = {
							keys = { ["dd"] = { "harpoon_delete", mode = { "n", "x" } } },
						},
					},
					actions = {
						harpoon_delete = function(picker, item)
							local to_remove = item or picker:selected()
							list():remove({ value = to_remove.text })
							list().items = normalize_list(list().items)
							picker:find({ refresh = true })
						end,
					},
				})
			end, { desc = "Harpoon: Menu" })

			return {
				-- Snacks picker UI
				-- { "<leader>M", harpoon_menu_snacks, desc = "Harpoon: Menu (Snacks)" },

				-- Add / select slots
				{
					"<leader>ha",
					function()
						list():add()
					end,
					desc = "Harpoon: Add file",
				},
				{
					"<leader>1",
					function()
						list():select(1)
					end,
					desc = "Harpoon: Select 1",
				},
				{
					"<leader>2",
					function()
						list():select(2)
					end,
					desc = "Harpoon: Select 2",
				},
				{
					"<leader>3",
					function()
						list():select(3)
					end,
					desc = "Harpoon: Select 3",
				},
				{
					"<leader>4",
					function()
						list():select(4)
					end,
					desc = "Harpoon: Select 4",
				},

				-- Navigate list
				{
					"<leader>hp",
					function()
						list():prev()
					end,
					desc = "Harpoon: Prev",
				},
				{
					"<leader>hn",
					function()
						list():next()
					end,
					desc = "Harpoon: Next",
				}, -- change if <leader>n is used elsewhere
			}
		end,
	},
	---------------------------------------------------------------------------
	-- Conform keymaps
	---------------------------------------------------------------------------
	{
		"stevearc/conform.nvim",
		keys = {
			{
				"<leader>fw",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
	},
	---------------------------------------------------------------------------
	-- lazygit keymaps
	---------------------------------------------------------------------------
	{
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		"kdheepak/lazygit.nvim",
		keys = {
			{
				-- Run LazyGit command and set background to transparent
				"<leader>lg",
				"<cmd>LazyGit<cr>"
					.. "<cmd>hi LazyGitFloat guibg=NONE guifg=NONE<cr>"
					.. "<cmd>setlocal winhl=NormalFloat:LazyGitFloat<cr>",
				desc = "LazyGit",
			},
		},
	},
	---------------------------------------------------------------------------
	-- outline keymaps
	---------------------------------------------------------------------------
	{
		"hedyhli/outline.nvim",
		keys = {
			{ "<leader>o", "<cmd>Outline<CR>", desc = "Toggle [o]utline" },
		},
	},
	---------------------------------------------------------------------------
	-- misc keymaps
	---------------------------------------------------------------------------
	{
		"akinsho/bufferline.nvim",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Last buffer" },
		},
	},
	{
		"HakonHarnes/img-clip.nvim",
		keys = {
			{ "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
		},
	},

	-- Molten keymaps (only for notebook-ish files)
	{
		"benlubas/molten-nvim",
		ft = { "quarto", "markdown", "qmd", "python", "r", "julia" },
		keys = {
			{ "<localleader>me", ":MoltenEvaluateOperator<CR>", desc = "Molten: [e]val operator", mode = "n" },
			{ "<localleader>mo", ":noautocmd MoltenEnterOutput<CR>", desc = "Molten: [o]pen output", mode = "n" },
			{ "<localleader>mh", ":MoltenHideOutput<CR>", desc = "Molten: [h]ide output", mode = "n" },
			{ "<localleader>mr", ":MoltenReevaluateCell<CR>", desc = "Molten: [r]e-eval cell", mode = "n" },
			{ "<localleader>me", ":<C-u>MoltenEvaluateVisual<CR>gv", desc = "[M]olten: [e]val visual", mode = "v" },
			{ "<localleader>md", ":MoltenDelete<CR>", desc = "Molten: [d]elete cell", mode = "n" },
			{ "<localleader>mx", ":MoltenOpenInBrowser<CR>", desc = "Molten: open in browser", mode = "n" },
		},
	},

	-- Quarto runner keymaps (lazy-require functions on press)
	{
		"quarto-dev/quarto-nvim",
		ft = { "quarto", "markdown", "qmd" },
		keys = {
			{
				"<localleader>rc",
				function()
					require("quarto.runner").run_cell()
				end,
				desc = "Quarto: run cell",
				mode = "n",
			},
			{
				"<localleader>ra",
				function()
					require("quarto.runner").run_above()
				end,
				desc = "Quarto: run above",
				mode = "n",
			},
			{
				"<localleader>rA",
				function()
					require("quarto.runner").run_all()
				end,
				desc = "Quarto: run all",
				mode = "n",
			},
			{
				"<localleader>rl",
				function()
					require("quarto.runner").run_line()
				end,
				desc = "Quarto: run line",
				mode = "n",
			},
			{
				"<localleader>r",
				function()
					require("quarto.runner").run_range()
				end,
				desc = "Quarto: run visual range",
				mode = "v",
			},
			{
				"<localleader>RA",
				function()
					require("quarto.runner").run_all(true)
				end,
				desc = "Quarto: run all (all langs)",
				mode = "n",
			},
		},
	},
}
