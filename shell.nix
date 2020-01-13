let
  pkgs = import <nixpkgs> {
    overlays = import ./overlays;
    config = { };
  };
in pkgs.mkShell rec { nativeBuildInputs = with pkgs; [ niv ]; }
