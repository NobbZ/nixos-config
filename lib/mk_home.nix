{
  home-manager,
  self,
  ...
} @ inputs: username: hostname: system: nixpkgs: let
  args = inputs;
  entrypoint = "${self}/home/configurations/${username}@${hostname}.nix";
in
  home-manager.lib.homeManagerConfiguration {
    inherit username system;
    homeDirectory = "/home/${username}";

    pkgs = nixpkgs.legacyPackages.${system};

    configuration = {lib, ...}: {
      _module = {inherit args;};
      imports =
        [
          entrypoint
        ]
        ++ __attrValues self.homeModules;
    };
  }
