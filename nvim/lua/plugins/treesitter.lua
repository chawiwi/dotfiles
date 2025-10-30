-- lua/plugins/treesitter.lua
return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		-- adding this due to treesitter configuring first
		dependencies = {
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
