local wezterm = require("wezterm")

local act = wezterm.action
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

local is_linux = function()
	return wezterm.target_triple:find("linux") ~= nil
end

local is_darwin = function()
	return wezterm.target_triple:find("darwin") ~= nil
end

local is_windows = function()
	return wezterm.target_triple:find("windows") ~= nil
end

if not is_windows() then
	config.default_prog = is_darwin() and { "/opt/homebrew/bin/fish", "-l" } or { "/usr/bin/fish", "-l" }
end
if is_windows() then
	config.default_domain = "WSL:Arch"
end

config.window_padding = {
	left = 16,
	right = 16,
	top = 8,
	bottom = 8,
}
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 13.0
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "INTEGRATED_BUTTONS"
config.window_background_opacity = 0.98
config.macos_window_background_blur = 20

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
	mods = (is_linux() or is_windows()) and "ALT|SHIFT" or "CTRL|SHIFT",
	action = act.SplitVertical({
		domain = "CurrentPaneDomain",
	}),
})
table.insert(config.keys, {
	key = "v",
	mods = (is_linux() or is_windows()) and "ALT|SHIFT" or "CTRL|SHIFT",
	action = act.SplitHorizontal({
		domain = "CurrentPaneDomain",
	}),
})

return config
