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

      lib.mkHomeConfig = username: entrypoint:
        home-manager.lib.homeManagerConfiguration {
          inherit username;
          homeDirectory = "/home/${username}";
          system = "x86_64-linux";
          configuration = { ... }: {
            nixpkgs.overlays = overlays;
            imports = [ ./home.nix entrypoint ];
          };
        };

      homeConfigurations = {
        tux-nixos = self.lib.mkHomeConfig "nmelzer" ./hosts/tux-nixos.nix;
        delly-nixos = self.lib.mkHomeConfig "nmelzer" ./hosts/delly-nixos.nix;
        nixos = self.lib.mkHomeConfig "demo" ./hosts/nixos.nix;
      };

      packages.x86_64-linux = builtins.mapAttrs
        (_: config:
          config.activationPackage)
        self.homeConfigurations;

      devShell.x86_64-linux = pkgs.mkShell {
        name = "home-manager-shell";

        buildInputs = with pkgs; [ git lefthook nixpkgs-fmt nix-linter ];
      };
    };
}
