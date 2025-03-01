_: {
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.wezterm];

  xdg.configFile."wezterm/wezterm.lua".text =
    # lua
    ''
      -- Pull in the wezterm API
      local wezterm = require 'wezterm'

      -- This table will hold the configuration.
      local config = {}

      -- In newer versions of wezterm, use the config_builder which will
      -- help provide clearer error messages
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end

      -- This is where you actually apply your config choices

      -- For example, changing the color scheme:
      config.color_scheme = "Catppuccin Mocha"

      -- disable ligatures
      config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

      -- set the font
      config.font_dirs = { '${pkgs.departure-mono}/share/fonts/otf' }
      config.font_size = 11.0 * 1.25
      config.font = wezterm.font("Departure Mono")

      -- setting up keybindings
      config.keys = {
        -- The default is `C-Z` (so also pressing SHIFT), I prefer to not have SHIFT pressed
        { key = 'z', mods = 'CTRL', action = wezterm.action.TogglePaneZoomState, },
      }

      -- and finally, return the configuration to wezterm
      return config
    '';
}
