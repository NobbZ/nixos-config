{
  _file = ./lvm.nix;

  services.lvm = {
    boot.thin.enable = true;
    boot.vdo.enable = true;
    dmeventd.enable = true;
  };
}
