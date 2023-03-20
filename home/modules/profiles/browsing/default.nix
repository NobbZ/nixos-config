{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.browsing;

  graphicalBrowser =
    if pkgs.system == "x86_64-linux"
    then pkgs.google-chrome
    else pkgs.chromium;
in {
  options.profiles.browsing = {
    enable =
      lib.mkEnableOption
      "A profile that enables a browser for the GUI and the terminal";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config = {google-chrome = {enableWideVine = true;};};
    home.packages = [graphicalBrowser pkgs.lynx];
  };
}
