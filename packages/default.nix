{ self, ... }@inputs:

let
  pkgs = inputs.nixpkgs-2105.legacyPackages.x86_64-linux;
  upkgs = inputs.unstable.legacyPackages.x86_64-linux;
  mpkgs = inputs.master.legacyPackages.x86_64-linux;
in
{
  advcp = pkgs.callPackage ./advcp { };
  gnucash-de = mpkgs.callPackage ./gnucash-de { };
  keyleds = upkgs.callPackage ./keyleds { };
}
