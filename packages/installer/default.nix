{
  nixosSystem,
  system,
  npins,
  nvim,
}:
nixosSystem {
  inherit system;

  specialArgs = {inherit npins nvim;};

  modules = [
    ./awesome.nix
    ./base.nix
    ./lvm.nix
    ./motd.nix
    ./neovim.nix
    ./network.nix
    ./sddm.nix
    ./xterm.nix
  ];
}
