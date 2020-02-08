let
  overlays = import ./nix;
  pkgs = import <nixpkgs> { overlays = overlays; };
in {
  nixpkgs.overlays = overlays;
  nixpkgs.config.allowUnfree = true;
  imports = [ ./modules ./profiles ./hosts ];
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    zshell.aliases = { hm = "cd ~/.config/nixpkgs"; };

    asdf-vm.enable = true;
    bat.enable = true;
    exa.enable = true;
    direnv.enable = true;
    jq.enable = true;

    irssi = {
      enable = true;
      networks = {
        freenode = {
          nick = "NobbZ";
          server = {
            address = "chat.freenode.net";
            port = 6697;
            autoConnect = true;
          };
          channels = {
            nixos.autoJoin = true;
            home-manager.autoJoin = true;
          };
        };
      };
    };

    htop = { enable = true; };

    tmux = {
      enable = true;

      clock24 = true;
      historyLimit = 10000;
      terminal = "screen-256color";
    };
  };

  services = {
    # lorri.enable = true;
  };

  manual.html.enable = true;

  home.packages = with pkgs; [
    aur-tools
    cachix
    niv
    # nix-prefetch-scripts
    nix-review
    nixfmt
    nixops
  ];
}
