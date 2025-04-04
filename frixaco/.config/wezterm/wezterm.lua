local wezterm = require("wezterm")
local mux = wezterm.mux

local act = wezterm.action
local config = {}

wezterm.on("gui-startup", function(cmd)
	mux.rename_workspace(mux.get_active_workspace(), "1")
end)

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

config.max_fps = 120
config.window_padding = {
	left = 10,
	right = 10,
	top = 8,
	bottom = 8,
}
-- config.font = wezterm.font("Monaspace Krypton")
-- on Windows, use "Fira Code"
config.font = is_windows() and wezterm.font("Fira Code") or wezterm.font("FiraCode Nerd Font")
config.font_size = 14.0
-- local function scheme_for_appearance(appearance)
-- 	if appearance:find("Dark") then
-- 		return "Catppuccin Mocha"
-- 	else
-- 		return "Catppuccin Latte"
-- 	end
-- end
-- config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "INTEGRATED_BUTTONS"
config.window_background_opacity = 0.98
config.macos_window_background_blur = 20
config.show_new_tab_button_in_tab_bar = false

config.window_frame = {
	-- on Windows, use "Fira Code"
	font = wezterm.font({ family = "FiraCode Nerd Font", weight = "Bold" }),
	font_size = 12.0,
	active_titlebar_bg = "#1e1e2e",
	inactive_titlebar_bg = "#1e1e2e",
}
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.6,
}

wezterm.on("update-right-status", function(window, pane)
	window:set_left_status("")
	window:set_right_status(wezterm.format({
		{ Background = { Color = "#cba6f7" } },
		{ Foreground = { Color = "#11111b" } },
		{ Text = " " .. window:active_workspace() .. " " },
	}))
end)

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#1e1e2e"
	local foreground = "#808080"

	if tab.is_active then
		background = "#cba6f7"
		foreground = "#11111b"
	elseif hover then
		background = "#3b3052"
		foreground = "#909090"
	end

	local pane = tab.active_pane
	local title = tab.tab_index + 1 .. ":" .. basename(pane.foreground_process_name)
	if tab.active_pane.pane_index > 0 then
		title = title .. ":" .. tab.active_pane.pane_index
	end

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = " " .. title .. " " },
	}
end)

config.keys = {
	{
		key = "R",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Rename workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line and line ~= "" then
					-- Retrieve the current workspace name
					local current_workspace = window:active_workspace()
					-- Rename the workspace to the new name provided by the user
					wezterm.mux.rename_workspace(current_workspace, line)
				end
			end),
		}),
	},

	{
		key = "N",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},

	{
		key = "1",
		mods = "CTRL|SHIFT",
		action = act.SwitchToWorkspace({
			name = "1",
		}),
	},

	{
		key = "2",
		mods = "CTRL|SHIFT",
		action = act.SwitchToWorkspace({
			name = "2",
		}),
	},

	{
		key = "3",
		mods = "CTRL|SHIFT",
		action = act.SwitchToWorkspace({
			name = "3",
		}),
	},

	{
		key = "0",
		mods = "ALT",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
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
