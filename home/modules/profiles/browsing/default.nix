{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.browsing;
in {
  options.profiles.browsing = {
    enable =
      lib.mkEnableOption
      "A profile that enables a browser for the GUI and the terminal";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config = {google-chrome = {enableWideVine = true;};};
    home.packages = with pkgs; [self.packages.x86_64-linux.google-chrome lynx];
  };
}
