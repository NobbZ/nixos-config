{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }@inputs: {
    devShell.x86_64-linux =
      nixpkgs.legacyPackages.x86_64-linux.callPackage
        ./packages/devShell.nix
        { };

    nixosModules = import ./modules;

    nixosConfigurations = import ./hosts inputs;
  };
}
