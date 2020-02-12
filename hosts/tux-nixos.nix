{ pkgs, config, ... }:

let
  keepassWithPlugins =
    pkgs.keepass.override { plugins = [ pkgs.keepass-keepasshttp ]; };
in {
  config = {
    home.packages =
      [ pkgs.chromium pkgs.insync keepassWithPlugins pkgs.keybase-gui ];

    services = {
      keyleds.enable = true;
      keybase.enable = true;
      kbfs.enable = true;
    };

    programs = {
      git = {
        enable = true;
        userEmail = "timmelzer@gmail.com";
        userName = "Norbert Melzer";
        aliases = {
          graph =
            "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold cyan)%h%C(reset) - %C(green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
          co = "checkout";
          br = "branch";
          st = "status";
          ps = "push";
          pl = "pull";
          root = "rev-parse --show-toplevel";
        };
        ignores = [
          # IntelliJ files and folders
          ".idea/"
          "*.iml"
          # backupfiles and shadow copies done by editors
          "*~"
          "#*#"
          ".#*"
          # Elixir language server
          "/.elixir_ls"
          # MyPy Cache
          ".mypy_cache"
          # Visual Studio Code project configuration
          "/.vscode"
          # Result folder for nix builds
          "result/"
        ];
        includes = [{
          condition = "gitdir:~cloudseeds/**";
          contents = { user.email = "norbert.melzer@cloudseeds.de"; };
        }];
      };

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
