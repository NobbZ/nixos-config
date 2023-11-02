{self, ...}: {config, pkgs, lib, ...}: let
  sshConfigPath = "${config.home.homeDirectory}/.ssh";
in {
  _file = ./nmelzer_at_phoebe.nix;

  nixpkgs.allowedUnfree = ["google-chrome" "vscode" "discord" "obsidian" "slack"];

  activeProfiles = ["development"];

  sops.age.sshKeyPaths = ["${sshConfigPath}/id_ed25519"];
  sops.defaultSopsFile = "${self}/secrets/phoebe/nmelzer/default.yaml";

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

  xsession.windowManager.awesome.enable = lib.mkForce false;
  xsession.enable = lib.mkForce false;

  services.playerctld.enable = true;
}
