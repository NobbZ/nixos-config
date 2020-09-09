{ self, nixpkgs, ... }:

{
  system = "x86_64-linux";

  modules =
    (with self.nixosModules; [ flake kubernetes ]) ++ [
      ../configuration.nix

      ./hardware/tux-nixos.nix
      nixpkgs.nixosModules.notDetected
    ];
}
