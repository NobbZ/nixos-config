{ config, pkgs, nixpkgs-2105, nix, lib, ... }:

{
  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    nix = {
      package = lib.mkDefault nix.packages.x86_64-linux.nix; # pkgs.nixUnstable;
      experimentalFeatures = "nix-command flakes";

      registry.nixpkgs.flake = nixpkgs-2105;
    };
  };
}
