{ config, lib, pkgs, ... }:

let cfg = config.profiles.base;

in {
  options.profiles.base = {
    enable = lib.mkEnableOption "The base profile, should be always enabled";
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = { EDITOR = "emacs"; };

    programs = {
      home-manager.enable = true;
      bat.enable = true;
      exa.enable = true;
      htop.enable = true;
      advancedCopy = true;

      emacs = {
        enable = true;
        package = pkgs.emacsGit;
      };

      tmux = {
        enable = true;

        clock24 = true;
        historyLimit = 10000;
        terminal = "screen-256color";
      };

      zshell.aliases = { hm = "cd ~/.config/nixpkgs"; };
      zsh = {
        enable = true;

        enableCompletion = true;
        enableAutosuggestions = true;

        dotDir = ".config/zsh";

        defaultKeymap = "emacs";

        plugins = [{
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }];

        shellAliases = config.programs.zshell.aliases;
      };
    };
  };
}
