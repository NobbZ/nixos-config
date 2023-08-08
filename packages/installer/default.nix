{
  nixosSystem,
  system,
  npins,
}:
nixosSystem {
  inherit system;

  specialArgs = {inherit npins;};

  modules = [
    ./awesome.nix
    ./base.nix
    ./lvm.nix
    ./network.nix
    ./sddm.nix
    ./xterm.nix
  ];
}
