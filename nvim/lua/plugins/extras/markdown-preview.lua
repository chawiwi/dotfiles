-- lua/plugins/extras/markdown-preview.lua
return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreview", "MarkdownPreviewStart", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
	-- don't gate on ft for now while debugging; cmd will lazy-load it
	-- ft = { "markdown" },

	build = function()
		local ok = pcall(function()
			vim.fn["mkdp#util#install"]()
		end)
		if not ok then
			local cmd = (vim.fn.executable("yarn") == 1)
				and "cd app && yarn install --frozen-lockfile --network-timeout 120000"
				or "cd app && npm install --no-audit --no-fund"
			vim.fn.system({ "sh", "-c", cmd })
		end
	end,

	init = function()
		-- Force a real opener (works on most Linux): use the system default browser
		-- You can swap to "firefox" if you prefer a specific browser.
		vim.g.mkdp_browser = "xdg-open"

		-- Show the preview URL in :messages (so you can copy it if the opener fails)
		vim.g.mkdp_echo_preview_url = 1

		vim.g.mkdp_auto_start = 0
		vim.g.mkdp_auto_close = 1
		vim.g.mkdp_page_title = "${name}"

		-- Optional: pick a highlight.js theme once node_modules exists
		-- local css = vim.fn.stdpath("data") ..
		--   "/lazy/markdown-preview.nvim/app/node_modules/highlight.js/styles/nord.css"
		-- if vim.fn.filereadable(css) == 1 then vim.g.mkdp_highlight_css = css end
	end,

	keys = {
		{ "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown Preview" },
	},
}
