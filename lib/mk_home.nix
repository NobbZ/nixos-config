{
  home-manager,
  self,
  ...
} @ inputs: username: hostname: system: nixpkgs: let
  args = inputs;
  entrypoint = import "${self}/home/configurations/${username}@${hostname}.nix" inputs;
in
  home-manager.lib.homeManagerConfiguration {
    inherit username system;
    homeDirectory = "/home/${username}";

    pkgs = nixpkgs.legacyPackages.${system};

    configuration = {lib, ...}: {
      imports =
        [
          entrypoint
        ]
        ++ __attrValues self.homeModules;
    };
  }
