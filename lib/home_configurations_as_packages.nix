{self, ...} @ inputs: let
  pkgs = import inputs.nixpkgs-2105 {system = "x86_64-linux";};

  inherit (pkgs.lib) genAttrs mapAttrs';

  hostNames = __attrNames self.homeConfigurations;
  attrHostNames = genAttrs hostNames (name: "home/config/${name}");
  configs =
    mapAttrs' (name: pname: {
      name = pname;
      value = self.homeConfigurations.${name}.activationPackage;
    })
    attrHostNames;
in {x86_64-linux = configs;}
