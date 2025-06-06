{
  self,
  nix,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  sshConfigPath = "${config.home.homeDirectory}/.ssh";
  inherit (lib.hm) dag;
  spkgs = self.packages.${pkgs.system};
in {
  nixpkgs.allowedUnfree = ["google-chrome" "vscode" "discord" "obsidian" "slack"];
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];
  profiles.base.needsGL = true;

  nix.checkConfig = false;
  nix.settings.extra-experimental-features = ["flakes" "nix-command"];
  nix.extraOptions = "!include ${config.sops.secrets."access-tokens".path}";
  nix.package = nix.packages.${pkgs.system}.nix-cli;

  activeProfiles = ["development"];

  sops.age.sshKeyPaths = ["${sshConfigPath}/id_ed25519"];
  sops.defaultSopsFile = "${self}/secrets/phoebe/nmelzer/default.yaml";

  sops.secrets.ssh.path = "${sshConfigPath}/nightwing_config";

  sops.secrets."access-tokens" = {
    path = "${config.home.homeDirectory}/.config/nix/access-tokens.conf";
    mode = "0400";
    sopsFile = "${self}/secrets/users/nmelzer/default.yaml";
  };

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

  sops.secrets."nobbz_dev" = {
    path = "${sshConfigPath}/nobbz_dev";
    mode = "0400";
    sopsFile = "${self}/secrets/users/nmelzer/nobbz_dev";
    format = "binary";
  };

  dconf.enable = true;

  home.packages = builtins.attrValues {
    inherit (pkgs) keepassxc nix-output-monitor discord obsidian vscode slack;
    inherit (config.nix) package;
    inherit (spkgs) switcher;
  };

  xsession.windowManager.awesome.enable = lib.mkForce false;
  xsession.enable = lib.mkForce false;

  services.playerctld.enable = true;

  gtk.gtk2.force = true;

  programs.ssh.includes = [
    config.sops.secrets.ssh.path
  ];

  programs.ssh.matchBlocks = {
    # TODO: properly use seperate key
    "gitlab.com-bravo" = dag.entryAfter ["gitlab.com"] {
      hostname = "gitlab.com";
      addressFamily = "inet";
      identityFile = "~/.ssh/id_ed25519";
    };

    # TODO: Make the actual hosts identity file configurable by other means. Actually moving all the logic over to `home/modules/profiles/base/default.nix`.
    "*.internal.nobbz.dev" = lib.mkForce (dag.entryAfter ["delly-nixos.adoring_suess.zerotier" "tux-nixos.adoring_suess.zerotier" "nixos.adoring_suess.zerotier"] {
      identityFile = "~/.ssh/id_ed25519";
      user = "nmelzer";
    });
  };

  home.stateVersion = "20.09";
}
