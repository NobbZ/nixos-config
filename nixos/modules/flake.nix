{ config, pkgs, unstable, nix, lib, ... }:

let
  nixpkgsPath = "/etc/nixpkgs/channels/nixpkgs";
in
{
  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    nix = {
      package = lib.mkDefault (nix.packages.x86_64-linux.nix.overrideAttrs (_: { patches = [ ./unset-is-macho.patch ]; })); # pkgs.nixUnstable;
      experimentalFeatures = "nix-command flakes";

      registry.nixpkgs.flake = unstable;

      nixPath = [
        "nixpkgs=${nixpkgsPath}"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath} - - - - ${unstable}"
    ];
  };
}
