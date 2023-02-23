inputs: let
  pkgs = inputs.unstable.legacyPackages.x86_64-linux;
  apkgs = inputs.alejandra.packages.x86_64-linux;

  callPackage = pkgs.lib.callPackageWith (pkgs // apkgs // {inherit (inputs) self;});
in {
  alejandra = callPackage ./alejandra.nix {};
  statix = callPackage ./statix.nix {};
}
