{ config, lib, pkgs, ... }:

let cfg = config.services.keyleds;

in {
  options.services.keyleds = {
    enable = lib.mkEnableOption
      "Logitech Keyboard animation for Linux — G410, G513, G610, G810, G910, GPro";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.keyleds;
      defaultText = lib.literalExample "pkgs.keyleds";
      example = lib.literalExample "pkgs.keyleds";
      description = ''
        Keyleds derivation to use.
      '';
    };
  };

  config = lib.mkIf cfg.enable { home.packages = [ cfg.package ]; };
}
