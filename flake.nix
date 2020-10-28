{
  inputs.nixpkgs.url = "github:nixos/nixpkgs-channels/nixos-20.03";
  inputs.nixpkgs-2009.url = "github:nixos/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs, nixpkgs-2009 }: {
    devShell.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        name = "nixos-builder";
        buildInputs = [ pkgs.gnumake pkgs.nixpkgs-fmt ];
      };

    nixosModules = {
      cachix = ./cachix.nix;
      flake = ./modules/flake.nix;
      kubernetes = ./modules/kubernetes.nix;
    };

    nixosConfigurations = {
      tux-nixos = nixpkgs.lib.nixosSystem (import ./hosts/tux-nixos.nix { inherit self nixpkgs; });
      nixos = nixpkgs.lib.nixosSystem (import ./hosts/nixos.nix { nixpkgs = nixpkgs-2009; inherit self; });
    };
  };
}
