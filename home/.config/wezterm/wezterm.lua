local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Dracula (Official)"
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Windows: bash, not PowerShell.
--
-- WezTerm's default on Windows is PowerShell, but this environment is bash all
-- the way down -- the custom commands, the agent hooks and ~/.bashrc all assume
-- it -- so point the default program at Git for Windows' bash. `-l` makes it a
-- login shell, which is what gets /etc/profile -> ~/.bash_profile -> ~/.bashrc
-- read and lands the shell in $HOME.
--
-- Git's own installer picks one of these locations depending on whether it was
-- a machine-wide or per-user install, so take the first that exists rather than
-- hard-coding one and breaking on the other.
if wezterm.target_triple:find("windows") then
	-- Built by appending rather than as a literal: any of these can be unset,
	-- and a nil inside a table constructor puts a hole in the list that ipairs
	-- stops at, silently skipping every candidate after it.
	local roots = {}
	for _, name in ipairs({ "ProgramW6432", "ProgramFiles", "ProgramFiles(x86)" }) do
		local value = os.getenv(name)
		if value and value ~= "" then
			table.insert(roots, value)
		end
	end
	local localappdata = os.getenv("LOCALAPPDATA")
	if localappdata and localappdata ~= "" then
		-- Where a per-user (non-elevated) Git install lands.
		table.insert(roots, localappdata .. "\\Programs")
	end

	for _, root in ipairs(roots) do
		local bash = root .. "\\Git\\bin\\bash.exe"
		local handle = io.open(bash, "r")
		if handle then
			handle:close()
			config.default_prog = { bash, "-l" }
			break
		end
	end
end

-- Dim unfocused windows so the focused one is obvious at a glance.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
	if actual == nil or expected == nil then
		return actual == expected
	end
	return actual.hue == expected.hue
		and actual.saturation == expected.saturation
		and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	local text_hsb, opacity
	if not window:is_focused() then
		text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
		opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
	end

	-- Only write when one of the two values we own actually changes; a redundant
	-- set_config_overrides() call would trigger another config reload.
	if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
		return
	end

	overrides.foreground_text_hsb = text_hsb
	overrides.window_background_opacity = opacity
	window:set_config_overrides(overrides)
end)

return config
