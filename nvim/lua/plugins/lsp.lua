vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})

local mason_tools = {
	"bash-debug-adapter",
	"bash-language-server",
	"debugpy",
	"json-lsp",
	"lua-language-server",
	"marksman",
	"prettierd",
	"ruff",
	"shfmt",
	"stylua",
	"ty",
	"yaml-language-server",
}

vim.lsp.enable({
	"bash-language-server",
	"json-lsp",
	"lua-language-server",
	"marksman",
	"ruff",
	"ty",
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

require("mason-tool-installer").setup({
	ensure_installed = mason_tools,
	run_on_start = true,
})

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
