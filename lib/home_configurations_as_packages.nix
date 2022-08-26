{self, ...} @ inputs: let
  pkgs = inputs.nixpkgs-2105.legacyPackages.x86_64-linux;

  inherit (pkgs.lib) genAttrs mapAttrs';

  hostNames = builtins.attrNames self.homeConfigurations;
  attrHostNames = genAttrs hostNames (name: "home/config/${name}");
  configs =
    mapAttrs' (name: pname: {
      name = pname;
      value = self.homeConfigurations.${name}.activationPackage;
    })
    attrHostNames;
in {x86_64-linux = configs;}
