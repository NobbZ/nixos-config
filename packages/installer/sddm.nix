{
  _file = ./sddm.nix;

  services.xserver = {
    displayManager.sddm.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "nixos";
  };
}
