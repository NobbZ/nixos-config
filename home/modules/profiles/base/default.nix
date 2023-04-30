{self, ...}: {
  config,
  lib,
  pkgs,
  npins,
  ...
}: let
  cfg = config.profiles.base;

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
    home.packages = let
      optisave =
        pkgs.resholve.writeScriptBin "optisave" {
          inputs = builtins.attrValues {inherit (pkgs) fd pv gawk coreutils gnused;};
          interpreter = "${pkgs.bash}/bin/bash";
          execer = [
            # TODO: Make this `might` or `can` in the long run
            "cannot:${pkgs.fd}/bin/fd"
          ];
        } ''
          count=$(fd . /nix/store/.links/ | pv -l | wc -l)

          # TODO: make resholve understant the call to `stat`
          saved=$(fd . /nix/store/.links/ -X ${pkgs.coreutils}/bin/stat --format='%h %s' {} \
            | pv -altrpe -s $count \
            | awk '{sum += ($1 - 2) * $2} END {print sum}')

          printf "Currently hardlinking saves %sB (%s B)\n" \
            "$(numfmt --to=iec-i --format='%.2f' ''${saved} \
              | sed -E 's/([0-9])([A-Za-z])/\1 \2/')" \
            "$(numfmt --to=none --format="%'f" ''${saved})"
        '';
    in
      [optisave pkgs.hydra-check] ++ lib.optionals pkgs.stdenv.isLinux [pkgs.dconf];

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
      fzf.enable = true;
      home-manager.enable = true;
      htop.enable = true;
      jq.enable = true;
      p10k.enable = true;

      ssh = {
        enable = true;
        compression = true;
        controlMaster = "auto";

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
            name = "fzf-tab";
            src = npins.fzf-tab;
          }
          {
            name = "nix-zsh-complete.zsh";
            src = zsh-complete;
            file = "_nix";
          }
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
