vim.pack.add({
	{ src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('1.*') },
})

require('blink.cmp').setup({
	keymap = { preset = 'default' },
	completion = { documentation = { auto_show = false } },
	sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
	snippets = { preset = 'mini_snippets' },
	fuzzy = { implementation = 'prefer_rust_with_warning' },
})
