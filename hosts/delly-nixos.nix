{ pkgs, config, ... }:

{
  config = {
    programs.zsh = {
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
}
