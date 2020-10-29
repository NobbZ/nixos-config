{ self, nixpkgs, ... }:

{
  system = "x86_64-linux";

  modules =
    (with self.nixosModules; [ cachix flake ]) ++ [
      ./legacy/delly-nixos.nix

      ./hardware/delly-nixos.nix
      nixpkgs.nixosModules.notDetected
    ];
}
