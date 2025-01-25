_: {pkgs, ...}: {
  xdg.configFile."ghostty/config".text =
    # toml
    ''
      font-family = "Cascadia Mono"

      ## uncomment once keybindings have been set to something I am familiar
      ## with. The bar contains the menu, which I need for splits for now…
      # gtk-titlebar = false

      theme = "catppuccin-mocha"
    '';

  home.packages = [pkgs.ghostty];
}
