{ pkgs, config, ... }:

let
  keepassWithPlugins =
    pkgs.keepass.override { plugins = [ pkgs.keepass-keepasshttp ]; };
in {
  config = {
    profiles.development.enable = true;

    home.packages =
      [ pkgs.chromium pkgs.insync keepassWithPlugins pkgs.keybase-gui ];

    services = {
      keyleds.enable = true;
      keybase.enable = true;
      kbfs.enable = true;
    };

    programs = {
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

    systemd.user.services = {

      keybase-gui = {
        Unit = {
          Description = "Keybase GUI";
          Requires = [ "keybase.service" "kbfs.service" ];
          After = [ "keybase.service" "kbfs.service" ];
        };
        Service = {
          ExecStart = "${pkgs.keybase-gui}/share/keybase/Keybase";
          PrivateTmp = true;
          # Slice      = "keybase.slice";
        };
      };
    };
  };
  # environment.pathsToLink = [ "/share/zsh" ];
}
