{ config, lib, pkgs, ... }:

let cfg = config.profiles.browsing;

in {
  options.profiles.browsing = {
    enable = lib.mkEnableOption
      "A profile that enables a browser for the GUI and the terminal";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config = { chromium = { enableWideVine = true; }; };
    home.packages = with pkgs; [ chromium lynx ];
  };
}
