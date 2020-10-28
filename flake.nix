{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }@inputs: {
    devShell.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        name = "nixos-builder";
        buildInputs = [ pkgs.gnumake pkgs.nixpkgs-fmt pkgs.git ];
      };

    nixosModules = import ./modules;

    nixosConfigurations = import ./hosts inputs; # with nixpkgs.lib; {
    #   tux-nixos = nixosSystem (import ./hosts/tux-nixos.nix inputs);
    #   nixos = nixosSystem (import ./hosts/nixos.nix inputs);
    # };
  };
}
