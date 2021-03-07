{ nixpkgs, self, ... }@inputs:
let
  inherit (nixpkgs.lib) nixosSystem;

  mkSystem = name: nixpkgs: modules:
    nixpkgs.lib.nixosSystem ({
      extraArgs = inputs;

      system = "x86_64-linux";

      modules = [
        (./. + "/legacy/${name}.nix")
        (./. + "/hardware/${name}.nix")
        nixpkgs.nixosModules.notDetected
      ] ++ modules;
    });
in
{
  delly-nixos = mkSystem "delly-nixos" nixpkgs (with self.nixosModules; [ cachix flake k3s gc version ]);
  tux-nixos = mkSystem "tux-nixos" nixpkgs (with self.nixosModules; [ cachix flake intel gc version ]);
  nixos = mkSystem "nixos" inputs.unstable (with self.nixosModules; [ cachix flake virtualbox-demo gc version ]);
}
