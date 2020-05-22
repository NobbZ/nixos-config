let
  overlays = import ./nix;
  pkgs = import <nixpkgs> { overlays = overlays; };
in {
  nixpkgs.overlays = overlays;
  nixpkgs.config.allowUnfree = true;

  imports = [ ./modules ./profiles ./hosts ]
    ++ (if builtins.pathExists ./secrets.nix then [ ./secrets.nix ] else [ ]);

  profiles.base.enable = true;
  fonts.fontconfig.enable = true;

  programs = {
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
    lorri.enable = true;
  };

  manual.html.enable = true;

  xsession.windowManager.awesome.enable = true;

  home.packages = with pkgs; [
    cachix
    niv
    # nix-prefetch-scripts
    nix-review
    (haskell.lib.doJailbreak haskellPackages.nixfmt)
    # nixfmt
    nixops
  ];
}
