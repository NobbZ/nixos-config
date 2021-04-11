{ home-manager, ... }@inputs:

username: entrypoint:

home-manager.lib.homeManagerConfiguration {
  inherit username;
  homeDirectory = "/home/${username}";
  system = "x86_64-linux";
  configuration = { ... }: {
    nixpkgs.overlays = builtins.attrValues inputs.self.overlays;
    imports = [ ../home.nix entrypoint ];
  };
}
