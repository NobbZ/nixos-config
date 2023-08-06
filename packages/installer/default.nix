{
  nixosSystem,
  system,
}:
nixosSystem {
  inherit system;

  modules = [
    ./base.nix
    ./lvm.nix
    ./sddm.nix
    ./awesome.nix
  ];
}
