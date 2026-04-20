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
in {
  activeProfiles = ["browsing" "development"];

  xsession.windowManager.awesome.enable = lib.mkForce false;
  xsession.numlock.enable = lib.mkForce false;
  xsession.enable = lib.mkForce false;

  sops.age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];

  sops.secrets.ssh.path = "${sshConfigPath}/nightwing_config";
  sops.secrets.ssh.sopsFile = "${self}/secrets/users/nmelzer/default.yaml";

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

  programs.ssh.includes = [
    config.sops.secrets.ssh.path
    "~/.ssh/config.d/*.conf"
  ];

  programs.ssh.matchBlocks = {
    # TODO: properly use separate key
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

  programs.zsh.initContent = lib.mkMerge [
    (lib.mkOrder 500 "export ASDF_DATA_DIR=$HOME/.local/state/asdf")
    # Loading the completions from brew has issues due to ownership as the brew
    # folder is managed by another admin user and not root.
    # (lib.mkOrder 550 "fpath+=$(brew --prefix)/share/zsh/site-functions")
    "path=(\${ASDF_DATA_DIR:-$HOME/.asdf}/shims $path)"
  ];

  nix.settings.extra-experimental-features = ["flakes" "nix-command"];
  nix.extraOptions = "!include ${config.sops.secrets."access-tokens".path}";
  nix.package = nix.packages.${pkgs.stdenv.hostPlatform.system}.nix-cli;

  home.stateVersion = "26.05";
}
