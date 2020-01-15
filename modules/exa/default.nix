{ config, lib, pkgs, ... }:

let cfg = config.programs.exa;

in {
  options.programs.exa = {
    enable = lib.mkEnableOption "A modern version of 'ls'";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.exa ];

    programs.zshell.aliases = {
      ll =
        "exa --header --git --classify --long --binary --group --time-style=long-iso --links --all --all --group-directories-first --sort=name";
    };
  };
}
