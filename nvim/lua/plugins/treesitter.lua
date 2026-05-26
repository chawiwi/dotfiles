-- lua/plugins/treesitter.lua
local function patch_query_predicates_for_nvim_0_12()
	if vim.fn.has("nvim-0.12") ~= 1 then
		return
	end

	require("nvim-treesitter.query_predicates")

	local query = require("vim.treesitter.query")
	local opts = vim.fn.has("nvim-0.10") == 1 and { force = true, all = false } or true

	local html_script_type_languages = {
		importmap = "json",
		module = "javascript",
		["application/ecmascript"] = "javascript",
		["text/ecmascript"] = "javascript",
	}

	local non_filetype_match_injection_language_aliases = {
		ex = "elixir",
		pl = "perl",
		sh = "bash",
		uxn = "uxntal",
		ts = "typescript",
	}

	local function get_parser_from_markdown_info_string(injection_alias)
		local match = vim.filetype.match({ filename = "a." .. injection_alias })
		return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
	end

	local function error_message(str)
		vim.api.nvim_err_writeln(str)
	end

	local function valid_args(name, pred, count, strict_count)
		local arg_count = #pred - 1

		if strict_count then
			if arg_count ~= count then
				error_message(string.format("%s must have exactly %d arguments", name, count))
				return false
			end
		elseif arg_count < count then
			error_message(string.format("%s must have at least %d arguments", name, count))
			return false
		end

		return true
	end

	local function normalize_capture(match, id)
		local node = match[id]
		if type(node) == "table" then
			return node[1]
		end
		return node
	end

	query.add_predicate("nth?", function(match, _pattern, _bufnr, pred)
		if not valid_args("nth?", pred, 2, true) then
			return
		end

		local node = normalize_capture(match, pred[2])
		local n = tonumber(pred[3])
		if node and node:parent() and node:parent():named_child_count() > n then
			return node:parent():named_child(n) == node
		end

		return false
	end, opts)

	query.add_predicate("is?", function(match, _pattern, bufnr, pred)
		if not valid_args("is?", pred, 2) then
			return
		end

		local locals = require("nvim-treesitter.locals")
		local node = normalize_capture(match, pred[2])
		local types = { unpack(pred, 3) }

		if not node then
			return true
		end

		local _, _, kind = locals.find_definition(node, bufnr)

		return vim.tbl_contains(types, kind)
	end, opts)

	query.add_predicate("kind-eq?", function(match, _pattern, _bufnr, pred)
		if not valid_args(pred[1], pred, 2) then
			return
		end

		local node = normalize_capture(match, pred[2])
		local types = { unpack(pred, 3) }

		if not node then
			return true
		end

		return vim.tbl_contains(types, node:type())
	end, opts)

	query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
		local capture_id = pred[2]
		local node = normalize_capture(match, capture_id)
		if not node then
			return
		end
		local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
		local configured = html_script_type_languages[type_attr_value]
		if configured then
			metadata["injection.language"] = configured
		else
			local parts = vim.split(type_attr_value, "/", {})
			metadata["injection.language"] = parts[#parts]
		end
	end, opts)

	query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
		local capture_id = pred[2]
		local node = normalize_capture(match, capture_id)
		if not node then
			return
		end
		local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
		metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
	end, opts)

	query.add_directive("make-range!", function() end, opts)

	query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
		local id = pred[2]
		local node = normalize_capture(match, id)
		if not node then
			return
		end

		local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
		if not metadata[id] then
			metadata[id] = {}
		end
		metadata[id].text = string.lower(text)
	end, opts)
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false,
		build = ":TSUpdate",
		main = "nvim-treesitter",
		-- adding this due to treesitter configuring first
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			{
				"LiadOz/nvim-dap-repl-highlights",
				config = function()
					require("nvim-dap-repl-highlights").setup()
				end,
			},
		},
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"latex",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"powershell",
				"python",
				"query",
				"regex",
				"sql",
				"typst",
				"vim",
				"vimdoc",
				"yaml",
				"dap_repl", --debug REPL
			},
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			textobjects = {
				move = {
					enable = true,
					set_jumps = false,
					goto_next_start = {
						["]b"] = { query = "@code_cell.inner", desc = "next code block" },
					},
					goto_previous_start = {
						["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
					},
				},
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["ib"] = { query = "@code_cell.inner", desc = "in block" },
						["ab"] = { query = "@code_cell.outer", desc = "around block" },
					},
				},
				swap = {
					enable = true,
					swap_next = { ["<leader>msl"] = "@code_cell.outer" },
					swap_previous = { ["<leader>msh"] = "@code_cell.outer" },
				},
			},
		},
		config = function(_, opts)
			patch_query_predicates_for_nvim_0_12()
			require("nvim-treesitter.configs").setup(opts)

			-- language aliases for fenced code blocks
			vim.treesitter.language.register("bash", "sh")
			vim.treesitter.language.register("bash", "shell")
			vim.treesitter.language.register("bash", "zsh")
			-- add more if you use them, e.g.:
			vim.treesitter.language.register("javascript", "node")
			vim.treesitter.language.register("typescript", "ts")
			vim.treesitter.language.register("python", "py")
			vim.treesitter.language.register("powershell", "ps1")
			vim.treesitter.language.register("json", "jsonc")
		end,
	},
}
