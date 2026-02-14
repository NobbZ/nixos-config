{
  _file = ./sddm.nix;

  services.displayManager = {
    sddm.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "nixos";
  };
}
