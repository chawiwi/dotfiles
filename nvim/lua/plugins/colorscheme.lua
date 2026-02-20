local subtle_color = "#8c98b3" -- default comment and line numbers for tokyo-nights is too faded

return {
	"folke/tokyonight.nvim",
	priority = 1000, -- Make sure to load this before all the other start plugins.
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("tokyonight").setup({
			on_colors = function(colors)
				colors.comment = subtle_color
			end,
			on_highlights = function(hl, colors)
				hl.LineNr = { fg = subtle_color }
				hl.LineNrAbove = { fg = subtle_color }
				hl.LineNrBelow = { fg = subtle_color }

				-- Make Visual mode stand out more
				hl.Visual = { bg = "#445b9b" }

				-- Keep TS module/namespace coloring aligned with the active colorscheme.
				-- hl["@module"] = { link = "Type" }
				-- hl["@namespace"] = { link = "Type" }
				-- hl["@variable"] = { link = "Type" }
			end,
			styles = {
				comments = { italic = false }, -- copilot ghost text will use italic, to diffrentiate it from comments
			},
		})

		vim.cmd.colorscheme("tokyonight-night")
	end,
}

-- NORD THEME
-- return {
-- 	{
-- 		"shaunsingh/nord.nvim",
-- 		lazy = false, -- make sure we load this during startup if it is your main colorscheme
-- 		priority = 1000, -- make sure to load this before all the other start plugins
-- 		config = function()
-- 			-- Example config in lua
-- 			-- vim.g.nord_contrast = true       -- Make sidebars and popup menus like nvim-tree and telescope have a different background
-- 			vim.g.nord_borders = false       -- Enable the border between verticaly split windows visable
-- 			-- vim.g.nord_disable_background = true -- Disable the setting of background color so that NeoVim can use your terminal background
-- 			vim.g.set_cursorline_transparent = false -- Set the cursorline transparent/visible
-- 			vim.g.nord_italic = false        -- enables/disables italics
-- 			-- vim.g.nord_enable_sidebar_background = false -- Re-enables the background of the sidebar if you disabled the background of everything
-- 			vim.g.nord_uniform_diff_background = true -- enables/disables colorful backgrounds when used in diff mode
-- 			vim.g.nord_bold = false          -- enables/disables bold
--
-- 			-- Load the colorscheme
-- 			require("nord").set()
--
-- 			-- Function to set menu borders to transparent
-- 			-- local set_menu_border_transparency = function()
-- 			--   vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', fg = 'NONE' })
-- 			--   vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE', fg = 'NONE' })
-- 			-- end
--
-- 			-- Execute the function once after loading the colorscheme
-- 			-- set_menu_border_transparency()
--
-- 			-- local bg_transparent = true
-- 			--
-- 			-- -- Toggle background transparency
-- 			-- local toggle_transparency = function()
-- 			-- 	bg_transparent = not bg_transparent
-- 			-- 	vim.g.nord_disable_background = bg_transparent
-- 			-- 	vim.cmd([[colorscheme nord]])
-- 			-- 	-- set_menu_border_transparency()
-- 			-- end
-- 			--
-- 			-- vim.keymap.set("n", "<leader>bg", toggle_transparency, { noremap = true, silent = true })
-- 		end,
-- 	},
-- }
