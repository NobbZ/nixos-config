{self, ...} @ inputs: let
  pkgs = inputs.nixpkgs-2105.legacyPackages.x86_64-linux;

  inherit (pkgs.lib) genAttrs mapAttrs';

  hostNames = builtins.attrNames self.nixosConfigurations;
  attrHostNames = genAttrs hostNames (name: "nixos/config/${name}");
  configs =
    mapAttrs' (name: pname: {
      name = pname;
      value = self.nixosConfigurations.${name}.config.system.build.toplevel;
    })
    attrHostNames;
in {x86_64-linux = configs;}
