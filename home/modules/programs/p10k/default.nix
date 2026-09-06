_: {
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.p10k;
  zsh = config.programs.zsh.enable;

  zsh-async = pkgs.fetchFromGitHub {
    owner = "mafredri";
    repo = "zsh-async";
    tag = "v1.8.6";
    hash = "sha256-Js/9vGGAEqcPmQSsumzLfkfwljaFWHJ9sMWOgWDi0NI=";
  };
in {
  options = {
    programs.p10k.enable = lib.mkEnableOption "p10k";
  };

  config = lib.mkIf (cfg.enable && zsh) {
    programs.zsh.plugins = [
      {
        name = "zsh-async";
        src = zsh-async;
        file = "async.plugin.zsh";
      }
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
