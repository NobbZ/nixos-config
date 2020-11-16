{ config, lib, pkgs, ... }:
let
  cfg = config.profiles.base;

  dag = lib.hm.dag;

  # TODO: make these a bit more nice, so that repeating the hosts and individual config isn't necessary.
  zerotierHosts = [ "delly-nixos.adoring_suess.zerotier" "tux-nixos.adoring_suess.zerotier" "nixos.adoring_suess.zerotier" ];
in
{
  options.profiles.base = {
    enable = lib.mkEnableOption "The base profile, should be always enabled";
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = rec {
      EDITOR = "emacs -nw";
      VISUAL = "emacs";
      GIT_EDITOR = EDITOR;
    };

    home.keyboard.layout = "de";

    xsession = {
      enable = true;
      numlock.enable = true;
      profileExtra = ''
        setxkbmap de
      '';
    };

    programs = {
      home-manager.enable = true;
      bat.enable = true;
      exa.enable = true;
      htop.enable = true;
      advancedCopy.enable = true;
      openshift.enable = true;

      ssh = {
        enable = true;
        compression = true;

        matchBlocks = {
          "*.adoring_suess.zerotier" = dag.entryAfter zerotierHosts {
            identityFile = "~/.ssh/id_rsa";
            user = "nmelzer";
          };

          "delly-nixos.adoring_suess.zerotier".hostname = "172.24.199.101";
          "tux-nixos.adoring_suess.zerotier".hostname = "172.24.198.250";
          "nixos.adoring_suess.zerotier" = {
            hostname = "172.24.231.199";
            user = "demo";
          };

          "*.nobbz.dev" = {
            identityFile = "~/.ssh/nobbz_dev";
            user = "root";
          };

          "gitlab.com" = {
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

          "deploy-vogel.custpoc.cloudseeds.de" = dag.entryBefore [
            "*.custpoc.cloudseeds.de"
            "*.cloudseeds.de"
          ]
            {
              user = "cloudseeds";
              identityFile = "~/.ssh/vogel";
            };

          "*.custpoc.cloudseeds.de" = dag.entryBefore [ "*.cloudseeds.de" ] {
            user = "norbert.melzer";
            identityFile = "~/.ssh/actum-gitlab";
          };

          "*.cloudseeds.de" = {
            user = "norbert.melzer";
            identityFile = "~/.ssh/cloudseeds";
          };
        };
      };

      emacs = {
        enable = true;
        package = pkgs.emacsGit;
      };

      direnv.enable = true;

      tmux = {
        enable = true;

        clock24 = true;
        historyLimit = 10000;
        terminal = "screen-256color";
      };

      zshell.aliases = {
        hm = "cd ~/.config/nixpkgs";
        hmb = "pushd ~/.config/nixpkgs; make build; popd";
        hme = "home-manager edit";
        hmh = "home-manager-help";
        hmn = "pushd ~/.config/nixpkgs; make news; popd";
        hms = "pushd ~/.config/nixpkgs; make switch; popd";
        hmu = "nix-channel --update; hms";
        ngc = "sudo nix-collect-garbage --verbose --delete-older-than 14d";
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
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = lib.cleanSource ./p10k-config;
            file = "p10k.zsh";
          }
        ];

        initExtra = ''
          bindkey "^[[1;5D" backward-word
          bindkey "^[[1;5C" forward-word
        '';

        sessionVariables = {
          NIX_PATH = builtins.concatStringsSep ":" [
            "nixpkgs=${<nixpkgs>}"
            "nixos-config=/etc/nixos/configuration.nix"
            "/nix/var/nix/profiles/per-user/root/channels"
          ];
        };

        shellAliases = config.programs.zshell.aliases;
      };
    };
  };
}
