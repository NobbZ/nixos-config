{self, ...}: {config, pkgs, ...}: let
  sshConfigPath = "${config.home.homeDirectory}/.ssh";
in {
  _file = ./nmelzer_at_mimas.nix;

  nixpkgs.allowedUnfree = ["google-chrome" "vscode" "discord" "obsidian" "slack"];

  activeProfiles = ["browsing" "development"];

  sops.age.sshKeyPaths = ["${sshConfigPath}/id_ed25519"];
  sops.defaultSopsFile = "${self}/secrets/janus/nmelzer/default.yaml";

  sops.secrets."github" = {
    path = "${sshConfigPath}/github";
    mode = "0400";
    sopsFile = "${self}/secrets/users/nmelzer/github";
    format = "binary";
  };

  sops.secrets."gitlab" = {
    path = "${sshConfigPath}/gitlab";
    mode = "0400";
    sopsFile = "${self}/secrets/users/nmelzer/gitlab";
    format = "binary";
  };

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
