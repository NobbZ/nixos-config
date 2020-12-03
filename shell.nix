let
  sources = import ./nix/sources.nix;
  unstable = sources.nixpkgs-unstable;
  stable = sources."nixpkgs-20.09";
  # home-manager = sources.home-manager;

  pkgs = import unstable {
    overlays = import ./nix;
    config = { };
  };

  home-manager = (import sources.home-manager { inherit pkgs; }).home-manager;

  lefthook = pkgs.lefthook.override { buildGoModule = pkgs.buildGo114Module; };

  inherit (pkgs) git gnumake niv nixpkgs-fmt nix-prefetch-git nix-prefetch-github nix-linter;
in
pkgs.mkShell {
  name = "home-manager-shell";

  buildInputs = [ git niv gnumake lefthook home-manager nixpkgs-fmt nix-prefetch-git nix-prefetch-github nix-linter ];

  NIX_PATH =
    "nixpkgs=${unstable}:nixos=${stable}:home-manager=${home-manager}";
  HOME_MANAGER_CONFIG = "./home.nix";
}
