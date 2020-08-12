{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.03";

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      tux-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [ ./configuration.nix ./hardware-configuration/tux-nixos.nix nixpkgs.nixosModules.notDetected ];
      };
    };
  };
}
