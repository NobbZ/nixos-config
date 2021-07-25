{ nixpkgs-2105, ... }@inputs:
let
  system = "x86_64-linux";
  pkgs = import nixpkgs-2105 { inherit system; };
in
{
  build-config = pkgs.callPackage ./build-config.nix { };
  switch-config = pkgs.callPackage ./switch-config.nix { };
}
