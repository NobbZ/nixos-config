{
  nixosSystem,
  system,
  npins,
  nixvim,
}:
nixosSystem {
  inherit system;

  specialArgs = {inherit npins;};

  modules = [
    nixvim.nixosModules.nixvim
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
