{
  nixosSystem,
  system,
}:
nixosSystem {
  inherit system;

  modules = [
    ./awesome.nix
    ./base.nix
    ./lvm.nix
    ./sddm.nix
    ./xterm.nix
  ];
}
