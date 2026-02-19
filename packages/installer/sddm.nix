{
  _file = ./sddm.nix;

  services = {
    displayManager.sddm.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "nixos";
  };
}
