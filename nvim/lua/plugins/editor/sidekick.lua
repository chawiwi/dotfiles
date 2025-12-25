-- Plugin: folke/sidekick.nvim
-- Installed via store.nvim

return {
	"folke/sidekick.nvim",
	opts = {
		-- send picker selections to sidekick buffer
		picker = {
			actions = {
				sidekick_send = function(...)
					return require("sidekick.cli.picker.snacks").send(...)
				end,
			},
			win = {
				input = {
					keys = {
						["<a-a>"] = {
							"sidekick_send",
							mode = { "n", "i" },
						},
					},
				},
			},
		},
		cli = {
			mux = {
				backend = "tmux",
				enabled = true,
			},
		},
		-- disable nes since annoying
		nes = { enabled = false },
	},
	keys = {
		{
			"<leader>na",
			function()
				-- if there is a next edit, jump to it, otherwise apply it if any
				if not require("sidekick").nes_jump_or_apply() then
					return "<Tab>" -- fallback to normal tab
				end
			end,
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
		{
			"<leader>nc",
			function()
				require("sidekick.nes").clear()
			end,
			expr = true,
			desc = "Clear Next Edit Suggestion",
		},
		{
			"<leader>nd",
			function()
				require("sidekick.nes").disable()
			end,
			expr = true,
			desc = "disable Next Edit Suggestion",
		},
		{
			"<leader>ne",
			function()
				require("sidekick.nes").enable()
			end,
			expr = true,
			desc = "enable Next Edit Suggestion",
		},
		{
			"<leader>nt",
			function()
				require("sidekick.nes").toggle()
			end,
			expr = true,
			desc = "toggle Next Edit Suggestion",
		},
		{
			"<leader>nu",
			function()
				require("sidekick.nes").update()
			end,
			expr = true,
			desc = "Update Next Edit Suggestion",
		},
		{
			"<c-.>",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle",
			mode = {
				"n",
				"t",
				"i",
				"x",
			},
		},
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle CLI",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").select()
			end,
			-- Or to select only installed tools:
			-- require("sidekick.cli").select({ filter = { installed = true } })
			desc = "Select CLI",
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").close()
			end,
			desc = "Detach a CLI Session",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").send({
					msg = "{this}",
				})
			end,
			mode = { "x", "n" },
			desc = "Send This",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({
					msg = "{file}",
				})
			end,
			desc = "Send File",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({
					msg = "{selection}",
				})
			end,
			mode = { "x" },
			desc = "Send Visual Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Sidekick Select Prompt",
		},
		-- Example of a keybinding to open Codex directly
		{
			"<leader>ac",
			function()
				require("sidekick.cli").toggle({
					name = "codex",
					focus = true,
				})
			end,
			desc = "Sidekick Toggle Codex",
		},
	},
}
