let
  pkgs = import <nixpkgs> {
    overlays = import ./nix;
    config = { };
  };

  inherit (pkgs) niv lefthook;
in pkgs.mkShell { buildInputs = [ niv lefthook ]; }
