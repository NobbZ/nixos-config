{self, ...}: {
  config,
  pkgs,
  lib,
  ...
}: {
  activeProfiles = ["browsing" "development"];

  xsession.windowManager.awesome.enable = lib.mkForce false;
  xsession.numlock.enable = lib.mkForce false;
  xsession.enable = lib.mkForce false;

  sops.age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];

  home.stateVersion = "26.05";
}
