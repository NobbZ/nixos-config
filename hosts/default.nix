{ nixpkgs, self, ... }@inputs:
let
  inherit (nixpkgs.lib) nixosSystem;

  mkSystem = name: nixosSystem:
    nixosSystem ({
      extraArgs = inputs;
    } // (import (./. + "/${name}.nix") inputs));
in
{
  delly-nixos = mkSystem "delly-nixos" nixpkgs.lib.nixosSystem;
  tux-nixos = mkSystem "tux-nixos" nixpkgs.lib.nixosSystem;
  nixos = mkSystem "nixos" inputs.unstable.lib.nixosSystem;
}
