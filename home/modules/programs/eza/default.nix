_: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.eza;
in {
  _file = ./default.nix;

  config = lib.mkIf cfg.enable {
    programs.eza.package = pkgs.eza;
    programs.zsh.shellAliases = {
      ll = "eza --header --git --classify --long --binary --group --time-style=long-iso --links --all --all --group-directories-first --sort=name";
    };
  };
}
