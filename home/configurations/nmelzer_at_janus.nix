_: {pkgs, ...}: {
  _file = ./nmelzer_at_mimas.nix;

  nixpkgs.allowedUnfree = ["google-chrome" "vscode" "discord" "obsidian" "slack"];

  activeProfiles = ["browsing" "development"];

  dconf.enable = true;

  home.packages = builtins.attrValues {
    inherit (pkgs) keepassxc nix-output-monitor discord obsidian vscode slack;
  };

  xsession.windowManager.awesome.autostart = [
    "${pkgs.blueman}/bin/blueman-applet"
    "${pkgs.networkmanagerapplet}/bin/nm-applet"
  ];

  services.playerctld.enable = true;
}
