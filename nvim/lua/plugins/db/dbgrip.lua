return {
	{
		"joryeugene/dadbod-grip.nvim",
		version = "*",
		cmd = {
			"Grip",
			"GripClose",
			"GripConnect",
			"GripHistory",
			"GripQuery",
			"GripSchema",
			"GripTables",
		},
		keys = {
			{ "<leader>db", "<cmd>GripConnect<cr>", desc = "DB connect" },
			{ "<leader>dg", "<cmd>Grip<cr>", desc = "DB grid" },
			{ "<leader>dt", "<cmd>GripTables<cr>", desc = "DB tables" },
			{ "<leader>dq", "<cmd>GripQuery<cr>", desc = "DB query pad" },
			{ "<leader>ds", "<cmd>GripSchema<cr>", desc = "DB schema" },
			{ "<leader>dh", "<cmd>GripHistory<cr>", desc = "DB history" },
			{ "<leader>dc", "<cmd>GripClose<cr>", desc = "DB close" },
		},
		opts = {
			keymaps = {
				qpad_close = false,
			},
		},
		config = function(_, opts)
			local grip = require("dadbod-grip")

			grip.setup(opts)

			local group = vim.api.nvim_create_augroup("KaisawaDadbodGrip", { clear = true })

			local function buf_name(bufnr)
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return ""
				end
				return vim.api.nvim_buf_get_name(bufnr)
			end

			local function is_grip_buffer(bufnr)
				local name = buf_name(bufnr)
				if name:match("^grip://") then
					return true
				end

				local ok, view = pcall(require, "dadbod-grip.view")
				return ok and view._sessions[bufnr] ~= nil
			end

			local function close_window_or_replace(winid)
				if not vim.api.nvim_win_is_valid(winid) then
					return
				end

				local tabpage = vim.api.nvim_win_get_tabpage(winid)
				local wins = vim.api.nvim_tabpage_list_wins(tabpage)
				if #wins == 1 then
					vim.api.nvim_set_current_win(winid)
					vim.cmd("enew")
					return
				end

				pcall(vim.api.nvim_win_close, winid, true)
			end

			local function close_grip_workspace()
				local ok_view, view = pcall(require, "dadbod-grip.view")
				if ok_view and type(view.close_all_floats) == "function" then
					pcall(view.close_all_floats, nil)
				end

				local ok_schema, schema = pcall(require, "dadbod-grip.schema")
				if ok_schema and type(schema.close) == "function" then
					pcall(schema.close)
				end

				local tabpage = vim.api.nvim_get_current_tabpage()
				local wins = vim.api.nvim_tabpage_list_wins(tabpage)
				local grip_wins = {}
				local non_grip_wins = {}

				for _, winid in ipairs(wins) do
					local bufnr = vim.api.nvim_win_get_buf(winid)
					if is_grip_buffer(bufnr) then
						table.insert(grip_wins, winid)
					else
						table.insert(non_grip_wins, winid)
					end
				end

				if #grip_wins == 0 then
					return
				end

				if #non_grip_wins == 0 and vim.api.nvim_win_is_valid(grip_wins[1]) then
					vim.api.nvim_set_current_win(grip_wins[1])
					vim.cmd("enew")
				end

				for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
					if vim.api.nvim_win_is_valid(winid) then
						local bufnr = vim.api.nvim_win_get_buf(winid)
						if is_grip_buffer(bufnr) then
							pcall(vim.api.nvim_win_close, winid, true)
						end
					end
				end
			end

			local function configure_query_pad(bufnr)
				vim.schedule(function()
					if not vim.api.nvim_buf_is_valid(bufnr) then
						return
					end

					vim.opt_local.completeopt = { "menu", "menuone", "noselect", "noinsert", "popup" }

					local function fk(keys)
						return vim.api.nvim_replace_termcodes(keys, true, true, true)
					end

					vim.keymap.set("i", "<CR>", function()
						if vim.fn.pumvisible() == 1 then
							local info = vim.fn.complete_info({ "selected" })
							if info.selected ~= -1 then
								vim.api.nvim_feedkeys(fk("<C-y>"), "n", false)
							else
								vim.api.nvim_feedkeys(fk("<C-e><CR>"), "n", false)
							end
						else
							vim.api.nvim_feedkeys(fk("<CR>"), "n", false)
						end
					end, { buffer = bufnr, silent = true, desc = "Grip: confirm selected completion or newline" })
				end)
			end

			pcall(vim.api.nvim_del_user_command, "GripClose")
			vim.api.nvim_create_user_command("GripClose", close_grip_workspace, {
				desc = "Close dadbod-grip windows in the current tab",
			})

			vim.api.nvim_create_autocmd("BufEnter", {
				group = group,
				callback = function(args)
					local bufnr = args.buf
					local name = buf_name(bufnr)

					if name == "grip://query" then
						local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
						if first_line and first_line:match("^%-%- C%-Space:complete") then
							vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {
								"-- type for suggestions  C-Space:complete  C-CR:run  C-s:save  gA:ai  go:tables  gh:hist  gq:saved  gw:grid  gb:schema  gC:connect",
							})
							vim.bo[bufnr].modified = false
						elseif first_line and first_line:match("^%-%- C%-CR:run") then
							vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {
								"-- type for suggestions  C-Space:complete  C-CR:run  C-s:save  gA:ai  go:tables  gh:hist  gq:saved  gw:grid  gb:schema  gC:connect",
							})
							vim.bo[bufnr].modified = false
						end

						local ok, completion = pcall(require, "dadbod-grip.completion")
						if ok then
							pcall(vim.api.nvim_clear_autocmds, {
								group = "DadbodGripCompletion",
								buffer = bufnr,
								event = "BufEnter",
							})
							pcall(vim.api.nvim_clear_autocmds, {
								group = "DadbodGripCompletion",
								buffer = bufnr,
								event = "TextChangedI",
							})
							completion.setup_auto_complete(bufnr, function()
								return vim.b[bufnr].db or vim.g.db
							end)
						end

						configure_query_pad(bufnr)

						vim.keymap.set("n", "q", function()
							local winid = vim.fn.bufwinid(bufnr)
							if winid ~= -1 then
								close_window_or_replace(winid)
							end
						end, { buffer = bufnr, silent = true, nowait = true, desc = "Grip: close query pad" })
					elseif name == "grip://schema" or vim.bo[bufnr].filetype == "grip_schema" then
						vim.keymap.set("n", "q", function()
							local ok, schema = pcall(require, "dadbod-grip.schema")
							if ok and type(schema.close) == "function" then
								schema.close()
								return
							end

							local winid = vim.fn.bufwinid(bufnr)
							if winid ~= -1 then
								close_window_or_replace(winid)
							end
						end, { buffer = bufnr, silent = true, nowait = true, desc = "Grip: close schema sidebar" })
					end
				end,
			})
		end,
	},
}
