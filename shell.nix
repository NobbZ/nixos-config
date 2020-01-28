let
  pkgs = import <nixpkgs> {
    overlays = import ./nix;
    config = { };
  };
in pkgs.mkShell rec { nativeBuildInputs = with pkgs; [ niv lefthook ]; }
