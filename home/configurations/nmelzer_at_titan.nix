{
  pkgs,
  lib,
  ...
}: {
  _file = ./nmelzer_at_titan.nix;

  nixpkgs.allowedUnfree = [];

  activeProfiles = ["base" "development"];
  enabledLanguages = [];

  xsession.enable = lib.mkForce false;
  xsession.windowManager.awesome.enable = lib.mkForce false;
  xsession.numlock.enable = lib.mkForce false;

  gtk.theme.package = lib.mkForce null;

  home.packages = builtins.attrValues {
    inherit (pkgs) neovim;
  };
}
