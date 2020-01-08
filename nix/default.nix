{ sources ? import ./sources.nix { } }:

let
  niv = _: pkgs: { inherit sources; };
  asdf-vm = _: pkgs: { asdfVm = pkgs.callPackage ./asdf-vm.nix { }; };
in import sources.nixpkgs {
  overlays = [ niv asdf-vm ];
  config = { };
}
