{
  self,
  nix,
  nvim,
  ...
}: {
  config,
  lib,
  pkgs,
  npins,
  ...
}: let
  cfg = config.profiles.base;

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

  fzf-tab = pkgs.stdenv.mkDerivation {
    pname = "fzf-tab";
    version = "0-unstable-${npins.fzf-tab.revision}";

    src = npins.fzf-tab;

    # we need this patch due to a bug between fzf-tab and p10k:
    # https://github.com/Aloxaf/fzf-tab/issues/176
    patches = [./colums-fix.patch];

    installPhase = ''
      mkdir -p $out
      cp -rv . $out
    '';
  };
in {
  options.profiles.base = {
    enable = lib.mkEnableOption "The base profile, should be always enabled";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.nix-community = {
      path = "${config.home.homeDirectory}/.ssh/nix-community";
      mode = "0400";
      sopsFile = "${self}/secrets/users/nmelzer/nix-community";
      format = "binary";
    };

    manual.manpages.enable = false;

    services.vscode-server.enable = lib.mkDefault pkgs.stdenv.isLinux;

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    gtk.enable = true;
    gtk.theme.package = pkgs.gnome-themes-extra;
    gtk.theme.name = "Adwaita-dark";

    services.pueue.enable = true;

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
      [optisave pkgs.hydra-check nvim.packages.x86_64-linux.default] ++ lib.optionals pkgs.stdenv.isLinux [pkgs.dconf];

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
      direnv.nix-direnv.package = pkgs.nix-direnv.override {nix = nix.packages.${pkgs.system}.default;};
      eza.enable = true;
      fzf.enable = true;
      home-manager.enable = true;
      htop.enable = true;
      jq.enable = true;
      p10k.enable = true;
      zoxide.enable = true;

      ssh = {
        enable = true;
        compression = true;
        controlMaster = "auto";

        matchBlocks = {
          "*.internal.nobbz.dev" = dag.entryAfter zerotierHosts {
            identityFile = "~/.ssh/id_rsa";
            user = "nmelzer";
          };

          "build-box.nix-community.org" = {
            identityFile = config.sops.secrets.nix-community.path;
            user = "nobbz";
          };

          "aarch64-build-box.nix-community.org" = {
            identityFile = config.sops.secrets.nix-community.path;
            user = "nobbz";
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

      tmux = {
        enable = true;

        clock24 = true;
        historyLimit = 10000;
        terminal = "screen-256color";
      };

      zsh = {
        enable = true;

        enableCompletion = true;
        autosuggestion.enable = true;

        autocd = true;

        dotDir = ".config/zsh";

        defaultKeymap = "emacs";

        plugins = [
          {
            name = "fzf-tab";
            src = fzf-tab;
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
          PROMPT_EOL_MARK = "%F{243}¶%f";
        };

        shellAliases.fixstore = "sudo nix-store --verify --check-contents --repair";
        shellAliases.pq = "pueue";
      };
    };

    # htop has some nastly problem that is saves a new config when you change by which column to sort
    # this workaround will always overwrite any changes made by the running system
    xdg.configFile = lib.mkIf (config.programs.htop.settings != {}) {"htop/htoprc".force = true;};
  };
}
