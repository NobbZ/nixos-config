inputs: {
  cachix = import ./cachix inputs;
  flake = import ./flake.nix inputs;
  hostnames = import ./hostnames.nix inputs;
  kernel = import ./kernel.nix inputs;
  moonlander = import ./moonlander.nix inputs;
  nix = import ./nix.nix inputs;
  switcher = import ./switcher.nix inputs;
  talon = import ./talon.nix inputs;
  zerotier = import ./zerotier.nix inputs;
}
