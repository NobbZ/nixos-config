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
    {
      services.xserver = {
        windowManager.awesome.enable = true;
      };
    }
  ];
}
