{
  inputs.nixpkgs.url = "github:nixos/nixpkgs-channels/nixos-20.03";

  outputs = { self, nixpkgs }: {
    devShell.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        name = "nixos-builder";
        buildInputs = [ pkgs.gnumake pkgs.nixpkgs-fmt ];
      };

    nixosModules = {
      flake = ./modules/flake.nix;
      kubernetes = ./modules/kubernetes.nix;
    };

    nixosConfigurations = {
      tux-nixos = nixpkgs.lib.nixosSystem (import ./hosts/tux-nixos.nix { inherit self nixpkgs; });
    };
  };
}
