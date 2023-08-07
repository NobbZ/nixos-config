{
  nixosSystem,
  system,
  npins,
  wrapper-manager,
}:
nixosSystem {
  inherit system;

  specialArgs = {inherit npins wrapper-manager;};

  modules = [
    ./awesome.nix
    ./base.nix
    ./lvm.nix
    ./sddm.nix
    ./xterm.nix
  ];
}
