{ config, pkgs, unstable, nixpkgs-2105, nixpkgs-2111, nix, lib, ... }:

let
  base = "/etc/nixpkgs/channels";
  nixpkgsPath = "${base}/nixpkgs";
  nixpkgs2105Path = "${base}/nixpkgs2105";
  nixpkgs2111Path = "${base}/nixpkgs2111";
in
{
  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    nix = {
      package = lib.mkDefault (nix.packages.x86_64-linux.nix.overrideAttrs (_: { patches = [ ./unset-is-macho.patch ]; })); # pkgs.nixUnstable;
      experimentalFeatures = "nix-command flakes";

      registry.nixpkgs.flake = unstable;
      registry.nixpkgs2105.flake = nixpkgs-2105;
      registry.nixpkgs2111.flake = nixpkgs-2111;

      nixPath = [
        "nixpkgs=${nixpkgsPath}"
        "nixpkgs2105=${nixpkgs2105Path}"
        "nixpkgs2111=${nixpkgs2111Path}"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath}     - - - - ${unstable}"
      "L+ ${nixpkgs2105Path} - - - - ${nixpkgs-2105}"
      "L+ ${nixpkgs2111Path} - - - - ${nixpkgs-2111}"
    ];
  };
}
