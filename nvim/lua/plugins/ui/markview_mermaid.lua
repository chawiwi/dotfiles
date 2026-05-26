local M = {}

local IMAGE_NAMESPACE = "markview-mermaid"
local TMP_DIR = (vim.uv.os_tmpdir() or "/tmp") .. "/nvim-markview-mermaid"

local state = {
	autocmds = false,
	jobs = {},
	notified_failures = {},
}

local function is_mermaid(item)
	local language = (item.language or ""):lower()
	return language == "mermaid" or language == "mmd"
end

local function changedtick(buffer)
	local ok, tick = pcall(vim.api.nvim_buf_get_changedtick, buffer)
	return ok and tick or -1
end

local function image_api()
	local ok, image = pcall(require, "image")
	if not ok or not image.is_enabled or not image.is_enabled() then
		return nil
	end

	return image
end

local function clear_buffer_images(buffer)
	local image = image_api()
	if not image then
		return
	end

	for _, img in ipairs(image.get_images({ buffer = buffer, namespace = IMAGE_NAMESPACE })) do
		img:clear()
	end
end

local function setup_autocmds()
	if state.autocmds then
		return
	end

	local group = vim.api.nvim_create_augroup("markview_mermaid", { clear = true })

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufDelete", "BufHidden", "BufWipeout" }, {
		group = group,
		callback = function(args)
			clear_buffer_images(args.buf)
		end,
	})

	state.autocmds = true
end

local function mermaid_source(item)
	if not item.text or #item.text <= 2 then
		return nil
	end

	local lines = {}
	for i = 2, #item.text - 1 do
		lines[#lines + 1] = item.text[i]
	end

	local source = table.concat(lines, "\n"):gsub("%s+$", "")
	if source == "" then
		return nil
	end

	return source .. "\n"
end

local function render_paths(source)
	vim.fn.mkdir(TMP_DIR, "p")

	local key = vim.fn.sha256(source)
	local input = TMP_DIR .. "/" .. key .. ".mmd"
	local output = TMP_DIR .. "/" .. key .. ".png"

	return key, input, output
end

local function target_window(buffer)
	local current = vim.api.nvim_get_current_win()
	if vim.api.nvim_win_is_valid(current) and vim.api.nvim_win_get_buf(current) == buffer then
		return current
	end

	local wins = vim.fn.win_findbuf(buffer)
	return wins[1]
end

local function render_image(buffer, item, output, key)
	local image = image_api()
	if not image then
		return
	end

	local win = target_window(buffer)
	if not win or win == -1 then
		return
	end

	local anchor_row = math.max(item.range.row_end - 1, item.range.row_start)
	local id = table.concat({
		IMAGE_NAMESPACE,
		buffer,
		win,
		item.range.row_start,
		key:sub(1, 12),
	}, ":")

	local ok, img = pcall(image.from_file, output, {
		id = id,
		window = win,
		buffer = buffer,
		x = 0,
		y = anchor_row,
		with_virtual_padding = true,
		render_offset_top = 1,
		namespace = IMAGE_NAMESPACE,
	})

	if not ok or not img then
		return
	end

	img.ignore_global_max_size = true
	img.max_width_window_percentage = 95
	img.max_height_window_percentage = 40
	img:render()
end

local function render_async(buffer, item, source, key, input, output)
	if state.jobs[key] then
		return
	end

	local mmdc = vim.fn.exepath("mmdc")
	if mmdc == "" then
		return
	end

	local request_tick = changedtick(buffer)
	vim.fn.writefile(vim.split(source, "\n", { plain = true }), input)

	state.jobs[key] = true
	vim.system({
		mmdc,
		"-i",
		input,
		"-o",
		output,
		"-b",
		"transparent",
	}, { text = true }, function(obj)
		state.jobs[key] = nil

		if obj.code ~= 0 or vim.uv.fs_stat(output) == nil then
			local err = (obj.stderr or obj.stdout or ""):gsub("%s+$", "")
			if err ~= "" and not state.notified_failures[err] then
				state.notified_failures[err] = true
				vim.schedule(function()
					vim.notify("Mermaid render failed: " .. err, vim.log.levels.WARN)
				end)
			end
			return
		end

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(buffer) or changedtick(buffer) ~= request_tick then
				return
			end

			render_image(buffer, item, output, key)
		end)
	end)
end

local function default_code_block_renderer(buffer, item)
	return require("markview.renderers.markdown").code_block(buffer, item)
end

function M.render_code_block(buffer, item)
	default_code_block_renderer(buffer, item)

	if not is_mermaid(item) or vim.fn.executable("mmdc") ~= 1 then
		return
	end

	local source = mermaid_source(item)
	if not source then
		return
	end

	local key, input, output = render_paths(source)
	if vim.uv.fs_stat(output) then
		render_image(buffer, item, output, key)
	else
		render_async(buffer, item, source, key, input, output)
	end
end

local function chain_callback(existing, extra)
	if type(existing) ~= "function" then
		return extra
	end

	return function(...)
		pcall(existing, ...)
		return extra(...)
	end
end

function M.apply(opts)
	opts.renderers = opts.renderers or {}
	opts.renderers.markdown_code_block = M.render_code_block

	opts.preview = opts.preview or {}
	opts.preview.callbacks = opts.preview.callbacks or {}
	opts.preview.callbacks.on_detach = chain_callback(opts.preview.callbacks.on_detach, function(buffer)
		clear_buffer_images(buffer)
	end)
	opts.preview.callbacks.on_disable = chain_callback(opts.preview.callbacks.on_disable, function(buffer)
		clear_buffer_images(buffer)
	end)

	setup_autocmds()

	return opts
end

return M
