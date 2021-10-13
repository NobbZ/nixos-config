{ self, ... }@inputs:

let
  args = inputs;
in
name: nixpkgs:
nixpkgs.lib.nixosSystem ({
  system = "x86_64-linux";

  modules = [
    {
      _module.args = args;
      networking.hostName = name;
      nix.flakes.enable = true;
      system.configurationRevision = self.rev or "dirty";
      documentation.man = { enable = true; generateCaches = true; };
    }
    (./. + "/../nixos/configurations/${name}.nix")
    (./. + "/../nixos/configurations/hardware/${name}.nix")
  ] ++ __attrValues self.nixosModules;
})
