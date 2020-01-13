{ config, lib, pkgs, ... }:

let cfg = config.programs.exa;

in {
  options.programs.exa = {
    enable = lib.mkEnableOption "A modern version of 'ls'";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.exa ];

    home.file = {
      ".zsh/boot/exa.zsh" = {
        text = ''
          alias ll="exa --header --git --classify --long --binary --group --time-style=long-iso --links --all --all --group-directories-first --sort=name"
        '';
      };
    };
  };
}
