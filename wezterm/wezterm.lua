local wezterm = require("wezterm")
local config = {}
local scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
-- scheme.background = "#000000"
-- Dynamically build tab bar colors using theme values
local tab_colors = {
	background = scheme.background,
	active_tab = {
		bg_color = scheme.ansi[5], -- e.g., blue
		fg_color = scheme.background,
	},
	inactive_tab = {
		bg_color = scheme.background,
		fg_color = scheme.ansi[7], -- light gray/white
	},
	inactive_tab_hover = {
		bg_color = scheme.ansi[8], -- bright black (hover)
		fg_color = scheme.background,
	},
	new_tab = {
		bg_color = scheme.background,
		fg_color = scheme.ansi[6], -- cyan accent
	},
	new_tab_hover = {
		bg_color = scheme.ansi[6],
		fg_color = scheme.background,
	},
}

config.color_schemes = { ["Chosen Theme"] = scheme }
config.color_scheme = "Chosen Theme"
config.colors = { tab_bar = tab_colors }
-- config.color_scheme = "Tokyo Night"
config.font = wezterm.font("Hack Nerd Font")
-- config.use_fancy_tab_bar = true
-- config.hide_tab_bar_if_only_one_tab = true
config.window_frame = {
	font = wezterm.font("Hack Nerd Font"),
	font_size = 10.0,
	active_titlebar_bg = tab_colors.background,
	inactive_titlebar_bg = tab_colors.background,
	active_titlebar_fg = tab_colors.active_tab.fg_color,
	inactive_titlebar_fg = tab_colors.inactive_tab.fg_color,
}
config.enable_scroll_bar = true
config.window_background_opacity = 0.9

return config
