{ sources ? import ./sources.nix {} }:

let
  niv = _: pkgs: { inherit sources; };
in import sources.nixpkgs {
  overlays = [ niv ];
  config = { };
}
