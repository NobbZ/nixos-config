{
  nobbz.nixosModules = {
    cachix.module = ./cachix;
    distributed.module = ./distributed.nix;
    flake.module = ./flake.nix;
    hostnames.module = ./hostnames.nix;
    kernel.module = ./kernel.nix;
    moonlander.module = ./moonlander.nix;
    nix.module = ./nix.nix;
    switcher.module = ./switcher.nix;
    zerotier.module = ./zerotier.nix;
  };
}
