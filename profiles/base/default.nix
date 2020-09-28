{ config, lib, pkgs, ... }:
let cfg = config.profiles.base;

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

      emacs = {
        enable = true;
        package = pkgs.emacsGit;
      };

      direnv = {
        enable = true;
        stdlib = ''
          source ${pkgs.direnv-nix}/direnvrc
        '';
      };

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
