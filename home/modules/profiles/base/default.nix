{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.base;

  inherit (self.packages.x86_64-linux) emacs;
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
    home.sessionVariables = rec {
      EDITOR = "emacs -nw";
      VISUAL = "emacs";
      GIT_EDITOR = EDITOR;
    };

    gtk.enable = true;
    gtk.theme.package = pkgs.gnome3.gnome-themes-extra;
    gtk.theme.name = "Adwaita-dark";

    home.keyboard.layout = "de";
    home.packages = [pkgs.hydra-check pkgs.dconf];

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
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = lib.cleanSource ./p10k-config;
            file = "p10k.zsh";
          }
          {
            name = "zsh-syntax-highlighting";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-syntax-highlighting";
              rev = "0.7.1";
              sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
            };
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

        shellAliases = lib.mkMerge [
          config.programs.zshell.aliases
          {
            fixstore = "sudo nix-store --verify --check-contents --repair";
          }
        ];
      };
    };
  };
}
