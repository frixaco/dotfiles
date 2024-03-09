local wezterm = require("wezterm")

local act = wezterm.action
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.default_prog = { "/opt/homebrew/bin/fish", "-l" }

config.window_padding = {
	left = 16,
	right = 16,
	top = 0,
	bottom = 0,
}
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13.0
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "RESIZE" -- "INTEGRATED_BUTTONS"
config.window_background_opacity = 0.98
config.macos_window_background_blur = 20

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

config.tab_bar_style = {
	new_tab = wezterm.format({
		{ Background = { Color = "#1e1e2e" } },
		{ Foreground = { Color = "#1e1e2e" } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = "#1e1e2e" } },
		{ Foreground = { Color = "#cba6f7" } },
		{ Text = "+" },
		{ Background = { Color = "#1e1e2e" } },
		{ Foreground = { Color = "#1e1e2e" } },
		{ Text = SOLID_RIGHT_ARROW },
	}),
	new_tab_hover = wezterm.format({
		{ Background = { Color = "#1e1e2e" } },
		{ Foreground = { Color = "#cba6f7" } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = "#cba6f7" } },
		{ Foreground = { Color = "#1e1e2e" } },
		{ Text = "+" },
		{ Background = { Color = "#1e1e2e" } },
		{ Foreground = { Color = "#cba6f7" } },
		{ Text = SOLID_RIGHT_ARROW },
	}),
}

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

config.window_frame = {
	-- The font used in the tab bar.
	-- Roboto Bold is the default; this font is bundled
	-- with wezterm.
	-- Whatever font is selected here, it will have the
	-- main font setting appended to it to pick up any
	-- fallback fonts you may have used there.
	font = wezterm.font({ family = "Roboto", weight = "Bold" }),

	-- The size of the font in the tab bar.
	-- Default to 10.0 on Windows but 12.0 on other systems
	font_size = 12.0,

	-- The overall background color of the tab bar when
	-- the window is focused
	active_titlebar_bg = "#1e1e2e",

	-- The overall background color of the tab bar when
	-- the window is not focused
	inactive_titlebar_bg = "#1e1e2e",
}

config.colors = {
	tab_bar = {
		-- The color of the strip that goes along the top of the window
		-- (does not apply when fancy tab bar is in use)
		background = "#1e1e2e",
	},
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local edge_background = "#1e1e2e"
	local background = "#1e1e2e"
	local foreground = "#808080"

	if tab.is_active then
		background = "#cba6f7"
		foreground = "#11111b"
	elseif hover then
		background = "#3b3052"
		foreground = "#909090"
	end

	local edge_foreground = background

	local title = tab_title(tab)
	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	title = wezterm.truncate_right(title, max_width - 2)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

wezterm.on("update-right-status", function(window, pane)
	window:set_left_status("")
	window:set_right_status("")
end)

config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = true

local function is_inside_vim(pane)
	local tty = pane:get_tty_name()
	if tty == nil then
		return false
	end

	local success, stdout, stderr = wezterm.run_child_process({
		"sh",
		"-c",
		"ps -o state= -o comm= -t"
			.. wezterm.shell_quote_arg(tty)
			.. " | "
			.. "grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'",
	})

	return success
end

local function is_outside_vim(pane)
	return not is_inside_vim(pane)
end

local function bind_if(cond, key, mods, action)
	local function callback(win, pane)
		if cond(pane) then
			win:perform_action(action, pane)
		else
			win:perform_action(act.SendKey({ key = key, mods = mods }), pane)
		end
	end

	return { key = key, mods = mods, action = wezterm.action_callback(callback) }
end

config.keys = {
	{ key = "s", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "a", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },

	bind_if(is_outside_vim, "h", "CTRL", act.ActivatePaneDirection("Left")),
	bind_if(is_outside_vim, "l", "CTRL", act.ActivatePaneDirection("Right")),
	bind_if(is_outside_vim, "k", "CTRL", act.ActivatePaneDirection("Up")),
	bind_if(is_outside_vim, "j", "CTRL", act.ActivatePaneDirection("Down")),
}

for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL",
		action = act.ActivateTab(i - 1),
	})
end

table.insert(config.keys, {
	key = "h",
	mods = "CTRL|SHIFT",
	action = act.SplitVertical({
		domain = "CurrentPaneDomain",
	}),
})
table.insert(config.keys, {
	key = "v",
	mods = "CTRL|SHIFT",
	action = act.SplitHorizontal({
		domain = "CurrentPaneDomain",
	}),
})

return config
