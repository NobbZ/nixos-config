{ home-manager, ... }@inputs:

username: entrypoint:

let system = "x86_64-linux"; in

home-manager.lib.homeManagerConfiguration {
  inherit username system;
  homeDirectory = "/home/${username}";
  configuration = { lib, ... }: {
    nixpkgs.overlays = builtins.attrValues inputs.self.overlays;
    nixpkgs.config.allowUnfreePredicate = (pkg: builtins.elem (lib.getName pkg) [
      "insync"
    ]);
    imports = [
      (_: {
        _module.args = {
          stable = inputs.nixpkgs.legacyPackages.${system};
          unstable = inputs.unstable.legacyPackages.${system};
          self = inputs.self.packages.${system};
        };
      })
      ../home.nix
      entrypoint
    ];
  };
}
