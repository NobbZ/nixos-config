{ self, ... }@args:

name: nixpkgs:
nixpkgs.lib.nixosSystem (
  let
    configFolder = "${self}/nixos/configurations";
    entryPoint = "${configFolder}/${name}.nix";
    hardware = "${configFolder}/hardware/${name}.nix";
  in
  {
    system = "x86_64-linux";

    modules = [
      {
        _module.args = args;
        networking.hostName = name;
        nix.flakes.enable = true;
        system.configurationRevision = self.rev or "dirty";
        documentation.man = { enable = true; generateCaches = true; };
      }
      entryPoint
      hardware
    ] ++ __attrValues self.nixosModules;
  }
)
