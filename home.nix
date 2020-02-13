let
  overlays = import ./nix;
  pkgs = import <nixpkgs> { overlays = overlays; };
in {
  nixpkgs.overlays = overlays;
  nixpkgs.config.allowUnfree = true;
  imports = [ ./modules ./profiles ./hosts ];

  profiles.base.enable = true;

  programs = {
    zshell.aliases = { hm = "cd ~/.config/nixpkgs"; };

    asdf-vm.enable = true;
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
  };

  services = {
    # lorri.enable = true;
  };

  manual.html.enable = true;

  home.packages = with pkgs; [
    aur-tools
    cachix
    emacsGit
    niv
    # nix-prefetch-scripts
    nix-review
    nixfmt
    nixops
  ];
}
