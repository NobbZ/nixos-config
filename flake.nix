{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      nixos = pkgs.recurseIntoAttrs {
        configs = pkgs.recurseIntoAttrs (builtins.mapAttrs
          (_: hostConfig: hostConfig.config.system.build.toplevel)
          self.nixosConfigurations);
      };
    in
    {
      devShell.x86_64-linux =
        nixpkgs.legacyPackages.x86_64-linux.callPackage
          ./packages/devShell.nix
          { };

      nixosModules = import ./nixos/modules;
      nixosConfigurations = import ./nixos/hosts inputs;

      checks.x86_64-linux =
        flake-utils.lib.flattenTree (pkgs.recurseIntoAttrs { inherit nixos; });

      packages.x86_64-linux = (import ./scripts inputs)
        // flake-utils.lib.flattenTree (pkgs.recurseIntoAttrs {
        inherit nixos;
      });

      apps.x86_64-linux = {
        build = { type = "app"; program = "${self.packages.x86_64-linux.build-config}/bin/build-config.sh"; };
        switch = { type = "app"; program = "${self.packages.x86_64-linux.switch-config}/bin/switch-config.sh"; };
      };
    };
}
