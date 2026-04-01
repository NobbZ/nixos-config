_: {
  pkgs,
  lib,
  ...
}: {
  programs.ghostty = {
    enable = pkgs.stdenv.isDarwin || pkgs.stdenv.isLinux;
    clearDefaultKeybinds = true;
    installBatSyntax = true;
    # FIXME: nix-community/home-manager#9011; integration causes GHOSTTY to restart even without any changes in the config
    systemd.enable = false;

    package =
      if pkgs.stdenv.isDarwin
      then pkgs.ghostty-bin
      else pkgs.ghostty;

    settings = {
      theme = "catppuccin-mocha";

      font-size = 11;
      font-family = "Iosevka Fixed Slab";
      font-feature = ["calt=0" "clig=0" "liga=0"];

      keybind = [
        # Pane management
        "ctrl+alt+shift+5=new_split:right"
        "ctrl+alt+shift+2=new_split:down"

        # Pane resizing
        "super+ctrl+shift+arrow_up=resize_split:up,5"
        "super+ctrl+shift+arrow_right=resize_split:right,5"
        "super+ctrl+shift+arrow_down=resize_split:down,5"
        "super+ctrl+shift+arrow_left=resize_split:left,5"

        # Pane switching
        "ctrl+shift+arrow_up=goto_split:up"
        "ctrl+shift+arrow_right=goto_split:right"
        "ctrl+shift+arrow_down=goto_split:down"
        "ctrl+shift+arrow_left=goto_split:left"

        # tab management
        "ctrl+shift+t=new_tab"

        # tab switching
        "ctrl+tab=next_tab"
        "ctrl+shift+tab=previous_tab"

        # Clipboard
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"

        "ctrl++=increase_font_size:1"
        "ctrl+-=decrease_font_size:1"
        "ctrl+0=reset_font_size"
        "ctrl+shift+z=toggle_split_zoom"
        "ctrl+z=toggle_split_zoom"
        "ctrl+shift+p=toggle_command_palette"
        "global:super+ctrl+shift+^=toggle_quick_terminal"
      ];
    };

    themes = {
      catppuccin-mocha = {
        background = "1e1e2e";
        cursor-color = "f5e0dc";
        foreground = "cdd6f4";
        palette = [
          "0=#45475a"
          "1=#f38ba8"
          "2=#a6e3a1"
          "3=#f9e2af"
          "4=#89b4fa"
          "5=#f5c2e7"
          "6=#94e2d5"
          "7=#bac2de"
          "8=#585b70"
          "9=#f38ba8"
          "10=#a6e3a1"
          "11=#f9e2af"
          "12=#89b4fa"
          "13=#f5c2e7"
          "14=#94e2d5"
          "15=#a6adc8"
        ];
        selection-background = "353749";
        selection-foreground = "cdd6f4";
      };
    };
  };
}
