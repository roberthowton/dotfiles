-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 100
config.initial_rows = 35

-- or, changing the font size and color scheme.
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 18

config.color_scheme = "catppuccin-mocha"

config.window_decorations = "RESIZE"
config.enable_tab_bar = false

-- Finally, return the configuration to wezterm:
return config
