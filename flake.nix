{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }@inputs: {
    devShell.x86_64-linux =
      nixpkgs.legacyPackages.x86_64-linux.callPackage
        ./packages/devShell.nix
        { };

    nixosModules = import ./modules;

    nixosConfigurations = import ./hosts inputs; # with nixpkgs.lib; {
    #   tux-nixos = nixosSystem (import ./hosts/tux-nixos.nix inputs);
    #   nixos = nixosSystem (import ./hosts/nixos.nix inputs);
    # };
  };
}
