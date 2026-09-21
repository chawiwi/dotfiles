local gen_loader = require('mini.snippets').gen_loader

require('mini.snippets').setup({
	-- `snippets/{filetype}.json` is discovered from this config's runtime path.
	-- Preserve the old VS Code package's `bash` -> `sh.json` association.
	snippets = { gen_loader.from_lang({ lang_patterns = { bash = { 'sh.json' } } }) },
})
