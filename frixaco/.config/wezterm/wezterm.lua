local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.window_padding = {
	left = 16,
	right = 16,
	top = 12,
	bottom = 12,
}
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13.0
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "RESIZE"

config.keys = {}
for i = 1, 8 do
	-- CTRL+ALT + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL",
		action = act.ActivateTab(i - 1),
	})
end

table.insert(config.keys, {
	key = "%",
	mods = "",
	action = act.SplitVertical({
		domain = "CurrentPaneDomain",
	}),
})
table.insert(config.keys, {
	key = "|",
	mods = "",
	action = act.SplitHorizontal({
		domain = "CurrentPaneDomain",
	}),
})

return config
