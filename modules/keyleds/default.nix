{ config, lib, pkgs, ... }:

let cfg = config.services.keyleds;

in {
  options.services.keyleds = {
    enable = lib.mkEnableOption
      "Logitech Keyboard animation for Linux — G410, G513, G610, G810, G910, GPro";
  };

  config = lib.mkIf cfg.enable { home.packages = [ pkgs.keyleds ]; };
}
