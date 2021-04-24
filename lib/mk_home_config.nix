{ home-manager, ... }@inputs:

username: entrypoint:

let
  system = "x86_64-linux";

  args = {
    stable = inputs.nixpkgs.legacyPackages.${system};
    unstable = inputs.unstable.legacyPackages.${system};
    self = inputs.self.packages.${system};
    inherit inputs;
  };
in
home-manager.lib.homeManagerConfiguration {
  inherit username system;
  homeDirectory = "/home/${username}";
  configuration = { lib, ... }: {
    _module = { inherit args; };
    nixpkgs.overlays = builtins.attrValues inputs.self.overlays;
    nixpkgs.config.allowUnfreePredicate = (pkg: builtins.elem (lib.getName pkg) [
      "insync" "teamspeak-client" "google-chrome" "steam" "steam-original"
      "steam-runtime"
    ]);
    imports = inputs.self.homeModules.all-modules ++ [
      ../home/profiles
      ../home/home.nix
      entrypoint
    ];
  };
}
