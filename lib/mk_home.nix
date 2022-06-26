{
  home-manager,
  self,
  ...
} @ inputs: username: hostname: system: nixpkgs: let
  args = inputs;
  entrypoint = import "${self}/home/configurations/${username}@${hostname}.nix" inputs;
  homeDirectory = "/home/${username}";
in
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};

    modules =
      [
        entrypoint
        {home = {inherit username homeDirectory;};}
      ]
      ++ __attrValues self.homeModules
      ++ __attrValues self.mixedModules;
  }
