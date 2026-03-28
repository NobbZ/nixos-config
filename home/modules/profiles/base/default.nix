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
        pkgs.writers.writePython3Bin "optisave" {libraries = pp: [pp.rich pp.humanize];}
        # python
        ''
          import os
          import stat
          from humanize import naturalsize
          from pathlib import Path
          from rich.console import Console
          from rich.progress import (
              BarColumn,
              MofNCompleteColumn,
              Progress,
              TaskProgressColumn,
              TextColumn,
              TimeRemainingColumn,
          )
          from rich.table import Table

          files = []
          num_files = 0
          total_size = 0
          optimized_size = 0


          def count_links(p, t_id):
              global num_files
              for file in Path("/nix/store/.links").iterdir():
                  files.append(file)
                  num_files = num_files + 1
                  if num_files % 100000 == 0:
                      p.reset(t_id, total=num_files, start=False)


          def sum_sizes(p, t_id):
              global optimized_size
              global total_size
              for file in files:
                  s = os.stat(file, follow_symlinks=False)
                  if not stat.S_ISLNK(s.st_mode):
                      optimized_size = optimized_size + s.st_size
                      total_size = total_size + s.st_size * s.st_nlink
                  p.advance(t_id)


          c = Console()
          with Progress(
              TextColumn("[progress.description]{task.description}"),
              BarColumn(bar_width=None),
              MofNCompleteColumn(),
              TaskProgressColumn(),
              TimeRemainingColumn(),
              expand=True,
              console=c,
          ) as p:
              t_id = p.add_task("Scanning Hardlinks", start=False, count=0, total=0)
              count_links(p, t_id)
              p.reset(t_id, total=num_files)
              sum_sizes(p, t_id)

          saved = total_size - optimized_size
          saved_human = naturalsize(saved, binary=True)
          optimized_human = naturalsize(optimized_size, binary=True)
          total_human = naturalsize(total_size, binary=True)

          t = Table()
          t.add_column("label", justify="left")
          t.add_column("size (hr)", justify="right")
          t.add_column("size (raw)", justify="right")

          t.add_row("unoptimized", str(total_human), str(total_size))
          t.add_row("real", str(optimized_human), str(optimized_size))
          t.add_row("saved", str(saved_human), str(saved))

          c.print(t)
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
