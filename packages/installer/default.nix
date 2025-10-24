{
  nixosSystem,
  system,
  npins,
  nvim,
  self',
}:
nixosSystem {
  inherit system;

  specialArgs = {inherit npins nvim self';};

  modules = [
    ./awesome.nix
    ./base.nix
    ./lvm.nix
    ./motd.nix
    ./network.nix
    ./sddm.nix
    ./xterm.nix
  ];
}
