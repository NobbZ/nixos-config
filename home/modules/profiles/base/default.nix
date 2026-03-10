{
  self,
  nix,
  nvim,
  nix-gl,
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

  iosevka = pkgs.iosevka.override {
    privateBuildPlan = {
      family = "Iosevka Fixed Slab";
      spacing = "fixed";
      serifs = "slab";
      noCvSs = true;
      exportGlyphNames = false;

      variants.design = {
        f = "serifless";
      };

      variants.italic = {
        f = "tailed";
      };

      weights.Regular = {
        shape = 400;
        menu = 400;
        css = 400;
      };

      weights.Bold = {
        shape = 700;
        menu = 700;
        css = 700;
      };
    };
  };
in {
  options.profiles.base = {
    enable = lib.mkEnableOption "The base profile, should be always enabled";

    needsGL = lib.mkEnableOption "nix-gl wrappers";
  };

  config = lib.mkIf cfg.enable {
    lib.nobbz = {inherit iosevka;};

    sops.secrets.nix-community = {
      path = "${config.home.homeDirectory}/.ssh/nix-community";
      mode = "0400";
      sopsFile = "${self}/secrets/users/nmelzer/nix-community";
      format = "binary";
    };

    programs.rbw.enable = true;

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
            "cannot:${pkgs.pv}/bin/pv"
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
      neovide =
        if cfg.needsGL
        then
          pkgs.writeShellScriptBin nvim.packages.x86_64-linux.nobbzvide.meta.mainProgram ''
            exec ${lib.getExe nix-gl.packages.x86_64-linux.nixGLIntel} ${lib.getExe nvim.packages.x86_64-linux.nobbzvide} "$@"
          ''
        else nvim.packages.x86_64-linux.nobbzvide;
    in
      lib.mkMerge [
        ([optisave pkgs.departure-mono iosevka pkgs.hydra-check nvim.packages.${pkgs.stdenv.hostPlatform.system}.nobbzvim] ++ lib.optionals pkgs.stdenv.isLinux [neovide])
        (lib.mkIf pkgs.stdenv.isLinux [pkgs.dconf])
      ];

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
      direnv.enable = true;
      direnv.nix-direnv.enable = true;
      direnv.nix-direnv.package = pkgs.nix-direnv.override {nix = nix.packages.${pkgs.stdenv.hostPlatform.system}.nix-cli;};
      eza.enable = true;
      fzf.enable = true;
      home-manager.enable = true;
      htop.enable = true;
      jq.enable = true;
      p10k.enable = true;
      zoxide.enable = true;

      bat = {
        enable = true;

        config.theme = "mocha";

        themes.mocha = {
          src = npins.catppuccin-bat;
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };

      ssh = {
        enable = true;
        enableDefaultConfig = false;

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

          "*" = {
            compression = true;
            forwardAgent = false;
            addKeysToAgent = "no";
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts";
          };
        };
      };

      tmux = {
        enable = true;

        clock24 = true;
        historyLimit = 10000;
        mouse = true;
        terminal = "tmux-256color";

        plugins = [
          {
            plugin = pkgs.tmuxPlugins.catppuccin;
            extraConfig = ''
              set -g @catppuccin_flavor "mocha"
              set -g @catppuccin_window_status_style "rounded"
            '';
          }
        ];

        extraConfig = ''
          set -ag terminal-overrides ",xterm-256color:RGB"
        '';
      };

      zsh = {
        enable = true;

        enableCompletion = true;
        autosuggestion.enable = true;

        autocd = true;

        dotDir = "${config.home.homeDirectory}/.config/zsh";

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

        initContent =
          # zsh
          ''
            # Ctrl+Left/Right on many Linux terminal emulators
            bindkey "^[[1;5D" backward-word
            bindkey "^[[1;5C" forward-word

            # macOS, option + left/right
            bindkey '^[[1;3D' backward-word
            bindkey '^[[1;3C' forward-word

            ZSH_AUTOSUGGEST_STRATEGY=(completion history)
          '';

        sessionVariables = {
          PROMPT_EOL_MARK = "%F{243}¶%f";
        };

        shellAliases.fixstore = "sudo nix-store --verify --check-contents --repair";
        shellAliases.pq = "pueue";
      };
    };
  };
}
