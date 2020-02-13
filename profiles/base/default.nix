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
      htop.enable = true;

      tmux = {
        enable = true;

        clock24 = true;
        historyLimit = 10000;
        terminal = "screen-256color";
      };
    };
  };
}
