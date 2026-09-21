vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/mason-org/mason.nvim" },
})

vim.lsp.enable({
	"bash-language-server",
	"ty",
	"json-lsp",
	"lua-language-server",
	"marksman",
	"yaml-language-server",
})

vim.lsp.config("lua-language-server", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { library = vim.api.nvim_get_runtime_file("", true) },
		},
	},
})

require("mason").setup()

require("nvim-treesitter").setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

require("nvim-treesitter").install({
	"bash",
	"json",
	"lua",
	"markdown",
	"python",
	"yaml",
	"regex",
	"latex",
})
