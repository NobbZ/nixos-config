{ lib, ... }:
let
  overlays = import ./nix;
  pkgs = import <nixpkgs> { overlays = overlays; };

  nixPath = builtins.concatStringsSep ":" [
    "nixpkgs=${<nixpkgs>}"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  optionalImport = path:
    lib.optional (builtins.pathExists path) path;
in
{
  nixpkgs.overlays = overlays;
  nixpkgs.config.allowUnfree = true;

  imports = [ ./modules ./profiles ./hosts ]
    ++ optionalImport ./secrets.nix;

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

  services = { lorri.enable = true; };
  systemd.user = {
    sessionVariables = { NIX_PATH = nixPath; };
    services.lorri.Service.Environment = [ "NIX_PATH=${nixPath}" ];
  };

  manual.html.enable = true;

  xsession.windowManager.awesome.enable = true;

  home = {
    sessionVariables = { NIX_PATH = nixPath; };

    packages = with pkgs; [
      cachix
      niv
      # nix-prefetch-scripts
      nix-review
      (haskell.lib.doJailbreak haskellPackages.nixfmt)
      # nixfmt
      exercism
      tmate
      element-desktop
      powershell

      (julia_13.overrideAttrs (oa: { doCheck = false; }))

      fira-code
    ];
  };
}
