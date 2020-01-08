{ sources ? import ./sources.nix { } }:

let
  niv = _: pkgs: { inherit sources; };
  asdf-vm = import ./asdf-vm.nix;
in import sources.nixpkgs {
  overlays = [ niv asdf-vm ];
  config = { };
}
