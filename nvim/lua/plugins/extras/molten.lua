return {
	{
		"benlubas/molten-nvim",
		version = "1.9.2", -- use version <2.0.0 to avoid breaking changes
		build = ":UpdateRemotePlugins",
		lazy = false,
		dependencies = { "3rd/image.nvim" },
		init = function()
			-- these are examples, not defaults. Please see the readme
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_wrap_output = true
			vim.g.molten_auto_open_output = false
			-- Output as virtual text. Allows outputs to always be shown, works with images, but can
			-- be buggy with longer images
			vim.g.molten_virt_text_output = true
			-- this will make it so the output shows up below the \`\`\` cell delimiter
			vim.g.molten_virt_lines_off_by_1 = true
		end,
		-- Optional: make the plugin (and our command) lazy-load when you call :NewNotebook
		cmd = { "NewNotebook" },

		config = function()
			------------------------------------------------------------------
			-- :NewNotebook <filename>  → creates <filename>.ipynb and opens it
			------------------------------------------------------------------
			local default_notebook = [[
{
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": [ "" ]
    }
  ],
  "metadata": {
    "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
    },
    "language_info": {
      "codemirror_mode": { "name": "ipython" },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
    }
  },
  "nbformat": 4,
  "nbformat_minor": 5
}
]]

			local function new_notebook(filename)
				if filename == nil or filename == "" then
					vim.notify("NewNotebook: provide a file name", vim.log.levels.WARN)
					return
				end
				local path = filename:match("%.ipynb$") and filename or (filename .. ".ipynb")

				-- create parent dirs if needed
				local dir = vim.fn.fnamemodify(path, ":h")
				if dir ~= "" and dir ~= "." then
					vim.fn.mkdir(dir, "p")
				end

				-- warn if overwriting
				if vim.loop.fs_stat(path) then
					vim.notify("NewNotebook: overwriting " .. path, vim.log.levels.WARN)
				end

				local f, err = io.open(path, "w")
				if not f then
					vim.notify("NewNotebook: could not write file: " .. (err or ""),
						vim.log.levels.ERROR)
					return
				end
				f:write(default_notebook)
				f:close()

				vim.cmd("edit " .. vim.fn.fnameescape(path))
			end

			vim.api.nvim_create_user_command("NewNotebook", function(opts)
				new_notebook(opts.args)
			end, { nargs = 1, complete = "file" })
		end,
	},
}
