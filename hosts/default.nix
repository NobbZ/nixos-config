{ nixpkgs, self, ... }@inputs:
let
  inherit (nixpkgs.lib) nixosSystem;
in
nixpkgs.lib.fold
  (p: attrs:
    attrs // {
      "${p}" = nixosSystem (import "${self}/hosts/${p}.nix" inputs);
    })
{ }
  [
    "delly-nixos"
    "nixos"
    "tux-nixos"
  ]
