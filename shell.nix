let
  sources = import ./nix/sources.nix;
  unstable = sources.nixpkgs-unstable;
  stable = sources.nixos-stable;

  pkgs = import unstable {
    overlays = import ./nix;
    config = { };
  };

  home-manager = (import sources.home-manager { inherit pkgs; }).home-manager;

  lefthook = pkgs.lefthook.override { buildGoModule = pkgs.buildGo114Module; };

  inherit (pkgs) git niv nixpkgs-fmt;
in
pkgs.mkShell {
  name = "home-manager-shell";

  buildInputs = [ git niv lefthook home-manager nixpkgs-fmt ];

  NIX_PATH =
    "nixpkgs=${unstable}:nixos=${stable}:home-manager=${sources.home-manager}";
  HOME_MANAGER_CONFIG = "./home.nix";
}
