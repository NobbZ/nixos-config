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

  outputs = { self, emacs, ... }@inputs:
    let
      pkgs = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        overlays = builtins.attrValues self.overlays;
      };
    in
    {
      overlay = import ./nix/myOverlay;

      overlays = {
        inputs = _: _: { inherit inputs; };
        emacs = emacs.overlay;
        self = self.overlay;
      };

      lib = import ./lib inputs;

      homeConfigurations = {
        tux-nixos = self.lib.mkHomeConfig "nmelzer" ./hosts/tux-nixos.nix;
        delly-nixos = self.lib.mkHomeConfig "nmelzer" ./hosts/delly-nixos.nix;
        nixos = self.lib.mkHomeConfig "demo" ./hosts/nixos.nix;
      };

      apps.x86_64-linux = {
        build = { type = "app"; program = "${self.packages.x86_64-linux.build-config}"; };
      };

      packages.x86_64-linux = {
        build-config = pkgs.writeShellScript "build-config.sh" ''
          set -ex

          if [ -z $1 ]; then
            name=$(${pkgs.nettools}/bin/hostname)
          else
            name=$1
          fi

          nix build --out-link "result-$name" ".#$name"
        '';
      } // builtins.mapAttrs
        (_: config:
          config.activationPackage)
        self.homeConfigurations;

      devShell.x86_64-linux = pkgs.mkShell {
        name = "home-manager-shell";

        buildInputs = with pkgs; [ git lefthook nixpkgs-fmt nix-linter ];
      };
    };
}
