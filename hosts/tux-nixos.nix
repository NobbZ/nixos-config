{ pkgs, config, ... }:

{
  config = {
    home.packages = [ ];

    services.keyleds.enable = true;

    programs = {
      zsh = {
        enable = true;

        enableCompletion = true;
        enableAutosuggestions = true;

        dotDir = ".config/zsh";

        shellAliases = config.programs.zshell.aliases;
      };
    };

  };
  # environment.pathsToLink = [ "/share/zsh" ];
}
