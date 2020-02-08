{ pkgs, config, ... }:

let
  keepassWithPlugins =
    pkgs.keepass.override { plugins = [ pkgs.keepass-keepasshttp ]; };
in {
  config = {
    home.packages = [ pkgs.chromium keepassWithPlugins ];

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
