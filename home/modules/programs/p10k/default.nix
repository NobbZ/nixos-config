_: {
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.p10k;
  zsh = config.programs.zsh.enable;
in {
  options = {
    programs.p10k.enable = lib.mkEnableOption "p10k";
  };

  config = lib.mkIf (cfg.enable && zsh) {
    programs.zsh.plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./p10k-config;
        file = "p10k.zsh";
      }
    ];
  };
}
