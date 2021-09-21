{ pkgs ? import <nixpkgs> {
    inherit system;
  }
, system ? builtins.currentSystem
}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };
in
nodePackages // {
  "@angular/cli" = nodePackages."@angular/cli".overrideAttrs (_: {
    NG_CLI_ANALYTICS = false;
  });
}
