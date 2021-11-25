{
  flake = import ./flake.nix;
  nix = import ./nix.nix;
  cachix = import ./cachix;
  hostnames = import ./hostnames.nix;
}
