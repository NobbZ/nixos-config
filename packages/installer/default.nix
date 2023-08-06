{
  nixosSystem,
  system,
}:
nixosSystem {
  inherit system;

  modules = [
    ./base.nix
    ./lvm.nix
    {
      services.xserver = {
        windowManager.awesome.enable = true;
        displayManager.sddm.enable = true;
        displayManager.autoLogin.enable = true;
        displayManager.autoLogin.user = "nixos";
      };
    }
  ];
}
