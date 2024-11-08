{
  nobbz.nixosModules = {
    cachix = ./cachix;
    distributed = ./distributed.nix;
    flake = ./flake.nix;
    hostnames = ./hostnames.nix;
    kernel = ./kernel.nix;
    moonlander = ./moonlander.nix;
    nix = ./nix.nix;
    switcher = ./switcher.nix;
    zerotier = ./zerotier.nix;
  };
}
