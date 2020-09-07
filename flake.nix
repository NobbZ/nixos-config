{
  inputs.nixpkgs.url = "github:nixos/nixpkgs-channels/nixos-20.03";

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      tux-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./configuration.nix

          ./modules/flake.nix
          ./modules/kubernetes.nix

          ./hardware-configuration/tux-nixos.nix
          nixpkgs.nixosModules.notDetected
        ];
      };
    };
  };
}
