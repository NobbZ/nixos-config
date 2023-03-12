{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.base;

  npins = import ../../../../npins;

  inherit (self.packages.${pkgs.system}) emacs;
  inherit (lib.hm) dag;

  # TODO: make these a bit more nice, so that repeating the hosts and individual config isn't necessary.
  zerotierHosts = ["delly-nixos.adoring_suess.zerotier" "tux-nixos.adoring_suess.zerotier" "nixos.adoring_suess.zerotier"];

  zsh-complete = pkgs.stdenv.mkDerivation {
    pname = "nix-zsh-completion-with-flakes";
    version = "git";

    src = ./nix-completions.sh;

    phases = ["installPhase"];

    installPhase = ''
      mkdir -p $out
      cp $src $out/_nix
    '';
  };
in {
  options.profiles.base = {
    enable = lib.mkEnableOption "The base profile, should be always enabled";
  };

  config = lib.mkIf cfg.enable {
    manual.manpages.enable = false;

    services.vscode-server.enable = lib.mkDefault pkgs.stdenv.isLinux;

    home.sessionVariables = rec {
      EDITOR = "emacs -nw";
      VISUAL = "emacs";
      GIT_EDITOR = EDITOR;
    };

    gtk.enable = true;
    gtk.theme.package = pkgs.gnome.gnome-themes-extra;
    gtk.theme.name = "Adwaita-dark";

    home.keyboard.layout = "de";
    home.packages = [pkgs.hydra-check] ++ lib.optionals pkgs.stdenv.isLinux [pkgs.dconf];

    # dconf.enable = lib.mkMerge [
    #   (lib.mkIf pkgs.stdenv.isLinux true)
    #   (lib.mkIf pkgs.stdenv.isDarwin false)
    # ];

    xsession = {
      enable = true;
      numlock.enable = true;
      profileExtra = ''
        setxkbmap de
      '';
    };

    programs = {
      advancedCopy.enable = true;
      bat.enable = true;
      direnv.enable = true;
      direnv.nix-direnv.enable = true;
      exa.enable = true;
      home-manager.enable = true;
      htop.enable = true;
      jq.enable = true;
      openshift.enable = true;

      starship = {
        enable = true;

        settings = {
          # disable the cloud modules, we don't use them
          aws.disabled = true;
          azure.disabled = true;
          openstack.disabled = true;

          # We will probably never use GUIX
          guix_shell.disabled = true;

          character = {
            success_symbol = "[\\$](bold green)";
            error_symbol = "[\\$](bold red)";
          };

          cmd_duration = {
            min_time = 500; # milliseconds => so half of a second
            show_milliseconds = true;
            show_notifications = true;
            min_time_to_notify = 60000; # milliseconds => 1 minute
          };

          directory = {
            truncation_length = 2;
            truncate_to_repo = false;
            fish_style_pwd_dir_length = 2;
            before_repo_root_style = "cyan";
            repo_root_style = "bold cyan";
            style = "blue dimmed";
          };

          nix_shell = {
            format = "via [$symbol]($style)";
          };

          os.disabled = false;
          status.disabled = false;
          sudo.disabled = false;
          time.disabled = false;
        };
      };

      ssh = {
        enable = true;
        compression = true;

        matchBlocks = {
          "*.internal.nobbz.dev" = dag.entryAfter zerotierHosts {
            identityFile = "~/.ssh/id_rsa";
            user = "nmelzer";
          };

          "ryzen-ubuntu.adoring_suess.zerotier" = {
            hostname = "172.24.237.73";
          };
          "mimas.internal.nobbz.dev" = {
            localForwards = [
              {
                bind.port = 60080;
                host.address = "fritz.box";
                host.port = 80;
              }
            ];
          };

          "*.nobbz.dev" = {
            identityFile = "~/.ssh/nobbz_dev";
            user = "root";
          };

          "gitlab.com" = {
            addressFamily = "inet";
            identityFile = "~/.ssh/gitlab";
          };

          "github.com" = {
            identityFile = "~/.ssh/github";
          };

          "*.actum.internal" = {
            user = "norbert.melzer";
            identityFile = "~/.ssh/actum-gitlab";
          };

          "*.vcp.internal" = {
            user = "cloudseeds";
            identityFile = "~/.ssh/vogel";
          };

          "deploy-vogel.custpoc.cloudseeds.de" =
            dag.entryBefore [
              "*.custpoc.cloudseeds.de"
              "*.cloudseeds.de"
            ]
            {
              user = "cloudseeds";
              identityFile = "~/.ssh/vogel";
            };

          "repo.cloudseeds.de" = dag.entryBefore ["*.cloudseeds.de"] {
            identityFile = "~/.ssh/id_rsa";
          };

          "*.custpoc.cloudseeds.de" = dag.entryBefore ["*.cloudseeds.de"] {
            user = "norbert.melzer";
            identityFile = "~/.ssh/actum-gitlab";
          };

          "com01.internal.cloudseeds.de" = dag.entryBefore ["*.cloudseeds.de"] {
            hostname = "192.168.123.22";
            user = "root";
          };

          "ironic.internal.cloudseeds.de" = dag.entryBefore ["*.cloudseeds.de"] {
            hostname = "192.168.123.31";
            user = "root";
          };

          "*.cloudseeds.de" = {
            user = "norbert.melzer";
            identityFile = "~/.ssh/cloudseeds";
          };

          "ironic" = {
            hostname = "192.168.123.31";
            user = "root";
            identityFile = "~/.ssh/cloudseeds";
          };
        };
      };

      emacs = {
        enable = true;
        package = emacs;
      };

      tmux = {
        enable = true;

        clock24 = true;
        historyLimit = 10000;
        terminal = "screen-256color";
      };

      zsh = {
        enable = true;

        enableCompletion = true;
        enableAutosuggestions = true;

        autocd = true;

        dotDir = ".config/zsh";

        defaultKeymap = "emacs";

        plugins = [
          {
            name = "nix-zsh-complete.zsh";
            src = zsh-complete;
            file = "_nix";
          }
          # {
          #   name = "powerlevel10k";
          #   src = pkgs.zsh-powerlevel10k;
          #   file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          # }
          # {
          #   name = "powerlevel10k-config";
          #   src = ./p10k-config;
          #   file = "p10k.zsh";
          # }
          {
            name = "zsh-syntax-highlighting";
            src = npins.zsh-syntax-highlighting;
          }
        ];

        initExtra = ''
          bindkey "^[[1;5D" backward-word
          bindkey "^[[1;5C" forward-word

          ZSH_AUTOSUGGEST_STRATEGY=(completion history)
        '';

        sessionVariables = {
          # NIX_PATH = builtins.concatStringsSep ":" [
          #   "nixpkgs=${inputs.nixpkgs}"
          #   "nixos-config=/etc/nixos/configuration.nix"
          #   "/nix/var/nix/profiles/per-user/root/channels"
          # ];
        };

        shellAliases.fixstore = "sudo nix-store --verify --check-contents --repair";
      };
    };
  };
}
