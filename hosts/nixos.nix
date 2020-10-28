{ self, nixpkgs, ... }:

{
  system = "x86_64-linux";

  modules =
    (with self.nixosModules; [ cachix flake ]) ++ [
      ./legacy/nixos.nix

      ./hardware/nixos.nix
      nixpkgs.nixosModules.notDetected
      ({modulesPath, ...}: { imports = [ (modulesPath + "/installer/virtualbox-demo.nix") ]; })
    ];
}
