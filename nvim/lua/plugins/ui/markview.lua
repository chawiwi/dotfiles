-- lua/plugins/ui/markview.lua
return {
	"OXY2DEV/markview.nvim",
	priority = 49,
	dependencies = { "nvim-treesitter/nvim-treesitter" },

	opts = {
		presets = { "all" }, -- keep if you like Markview's default UX bits
		markdown = {
			-- no require("markview.presets") to avoid version issues
			code_blocks = {
				enable = true,
				style = "block",
				delimiters = { conceal = true },
				pad_amount = 1,
				pad_char = " ",
				block_hl = "MarkviewCodeBlock",
				pad_hl = "MarkviewCodePad",
				info_hl = "MarkviewCodeInfo",
			},
		},
	},

	config = function(_, opts)
		require("markview").setup(opts)

		local function HL(g, t)
			pcall(vim.api.nvim_set_hl, 0, g, t)
		end

		-- === Code blocks (Nord dark) ===
		local nord = {
			bg2 = "#2E3440",
			blue = "#81A1C1",
			y = "#EBCB8B",
		}
		HL("MarkviewCodeBlock", { bg = nord.bg2 })
		HL("MarkviewCodePad", { bg = nord.bg2 })
		HL("MarkviewCodeInfo", { bg = nord.bg2, fg = nord.blue, italic = true })
		HL("MarkviewInlineCode", { bg = "NONE", fg = nord.y })

		-- === Headings H1..H6 (Nord accents pulled from your :hi) ===
		local heads = {
			"#88C0D0", -- H1
			"#BF616A", -- H2
			"#A3BE8C", -- H3
			"#B48EAD", -- H4
			"#81A1C1", -- H5
			"#EBCB8B", -- H6
		}
		for i = 1, 6 do
			HL("MarkviewHeading" .. i, { fg = heads[i], bold = true })
			HL("MarkviewPalette" .. i, { fg = heads[i], bold = true }) -- some versions link via Palette*
		end
		-- odd historical alias in some versions; harmless if unused
		HL("Markviewheading4", { fg = heads[4], bold = true })

		-- === 10-stop gradient tail (warm → cool), all Nord family tones ===
		local grad = {
			"#BF616A",
			"#D08770",
			"#EBCB8B",
			"#A3BE8C",
			"#8FBCBB",
			"#88C0D0",
			"#81A1C1",
			"#5E81AC",
			"#B48EAD",
			"#D8DEE9",
		}
		for i = 0, 9 do
			HL("MarkviewGradient" .. i, { fg = grad[i + 1], bg = "NONE" })
		end

		-- Reapply on colorscheme change (themes can reset groups)
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				HL("MarkviewCodeBlock", { bg = nord.bg2 })
				HL("MarkviewCodePad", { bg = nord.bg2 })
				HL("MarkviewCodeInfo", { bg = nord.bg2, fg = nord.blue, italic = true })
				HL("MarkviewInlineCode", { bg = "NONE", fg = nord.y })
				for i = 1, 6 do
					HL("MarkviewHeading" .. i, { fg = heads[i], bold = true })
					HL("MarkviewPalette" .. i, { fg = heads[i], bold = true })
				end
				HL("Markviewheading4", { fg = heads[4], bold = true })
				for i = 0, 9 do
					HL("MarkviewGradient" .. i, { fg = grad[i + 1], bg = "NONE" })
				end
			end,
		})
	end,
}
