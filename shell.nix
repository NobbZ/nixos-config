let
  pkgs = import <nixpkgs> {
    overlays = import ./overs;
    config = { };
  };
in pkgs.mkShell rec { nativeBuildInputs = with pkgs; [ niv lefthook ]; }
