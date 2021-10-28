{
  flake = import ./flake.nix;
  nix = import ./nix.nix;
  cachix = import ./cachix;

  "dns/server" = import ./dns/server;
}
