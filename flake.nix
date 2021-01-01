{
  inputs = {
    # Main channels
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-20.09";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Overlays
    emacs.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, home-manager, emacs, ... }@inputs:
    let
      overlays = [
        (_: _: { inherit inputs; })
        emacs.overlay
        self.overlay
      ];

      pkgs = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        inherit overlays;
      };
    in
    {
      overlay = import ./nix/myOverlay;
      homeConfigurations = {
        tux-nixos = home-manager.lib.homeManagerConfiguration {
          username = "nmelzer";
          homeDirectory = "/home/nmelzer";
          system = "x86_64-linux";
          configuration = { ... }: {
            nixpkgs.overlays = overlays;
            imports = [ ./home.nix ./hosts/tux-nixos.nix ];
          };
        };

        delly-nixos = home-manager.lib.homeManagerConfiguration {
          username = "nmelzer";
          homeDirectory = "/home/nmelzer";
          system = "x86_64-linux";
          configuration = { ... }: {
            nixpkgs.overlays = overlays;
            imports = [ ./home.nix ./hosts/delly-nixos.nix ];
          };
        };

        nixos = home-manager.lib.homeManagerConfiguration {
          username = "demo";
          homeDirectory = "/home/demo";
          system = "x86_64-linux";
          configuration = { ... }: {
            nixpkgs.overlays = overlays;
            imports = [ ./home.nix ./hosts/nixos.nix ];
          };
        };
      };

      devShell.x86_64-linux = pkgs.mkShell {
        name = "home-manager-shell";

        buildInputs = with pkgs; [ git lefthook nixpkgs-fmt nix-linter ];
      };
    };
}
