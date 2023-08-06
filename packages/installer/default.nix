{
  nixosSystem,
  system,
}:
nixosSystem {
  inherit system;

  modules = [
    ./base.nix
    {
      services.xserver = {
        windowManager.awesome.enable = true;
        displayManager.sddm.enable = true;
        displayManager.autoLogin.enable = true;
        displayManager.autoLogin.user = "nixos";
      };

      services.lvm = {
        boot.thin.enable = true;
        boot.vdo.enable = true;
        dmeventd.enable = true;
      };
    }
  ];
}
