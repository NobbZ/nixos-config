{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.exa;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.exa];

    programs.zshell.aliases = {
      ll = "exa --header --git --classify --long --binary --group --time-style=long-iso --links --all --all --group-directories-first --sort=name";
    };
  };
}
