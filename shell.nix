let
  sources = import ./nix/sources.nix;
  unstable = sources.nixpkgs-unstable;
  stable = sources.nixos-stable;

  pkgs = import unstable {
    overlays = import ./nix;
    config = { };
  };

  home-manager = (import sources.home-manager { inherit pkgs; }).home-manager;

  inherit (pkgs) niv lefthook;
in pkgs.mkShell {
  name = "home-manager-shell";

  buildInputs = [ niv lefthook home-manager ];

  NIX_PATH =
    "nixpkgs=${unstable}:nixos=${stable}:home-manager=${sources.home-manager}";
  HOME_MANAGER_CONFIG = "./home.nix";
}
