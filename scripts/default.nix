{ nixpkgs, ... }@inputs:
let
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; };
in
{
  build-config = pkgs.callPackage ./build-config.nix { };
  switch-config = pkgs.callPackage ./switch-config.nix { };
}
