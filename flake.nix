{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }@inputs: {
    devShell.x86_64-linux =
      nixpkgs.legacyPackages.x86_64-linux.callPackage
        ./packages/devShell.nix
        { };

    nixosModules = import ./modules;

    nixosConfigurations = import ./hosts inputs;

    packages.x86_64-linux = (import ./scripts inputs)
      // builtins.mapAttrs
        (_: hostConfig:
          hostConfig.config.system.build.toplevel)
        self.nixosConfigurations;

    apps.x86_64-linux = {
      build = { type = "app"; program = "${self.packages.x86_64-linux.build-config}/bin/build-config.sh"; };
      switch = { type = "app"; program = "${self.packages.x86_64-linux.switch-config}/bin/switch-config.sh"; };
    };
  };
}
