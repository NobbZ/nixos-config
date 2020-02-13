{ config, lib, pkgs, ... }:

let cfg = config.profiles.base;

in {
  options.profiles.base = {
    enable = lib.mkEnableOption "The base profile, should be always enabled";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      home-manager.enable = true;
      bat.enable = true;
      exa.enable = true;
    };
  };
}
