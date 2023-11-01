version = "0.21.3"

local home = os.getenv("HOME")
package.path = home .. "/.config/xplr/plugins/?/init.lua;" .. home .. "/.config/xplr/plugins/?.lua;" .. package.path

for name, mode in pairs(xplr.config.modes.builtin) do
	if mode.layout == "HelpMenu" then
		mode.layout = nil
	end
end
-- same for xplr.config.modes.custom

require("fzf").setup({
	mode = "default",
	key = "ctrl-f",
	bin = "fzf",
	-- args = "--preview 'pistol {}'",
	recursive = true, -- If true, search all files under $PWD
	enter_dir = true, -- Enter if the result is directory
})

require("dual-pane").setup({
	active_pane_width = { Percentage = 60 },
	inactive_pane_width = { Percentage = 40 },
	layout = "horizontal",
})
