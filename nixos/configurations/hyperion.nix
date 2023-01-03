_: {pkgs, ...}: {
  nix.allowedUnfree = ["zerotierone"];

  networking.hostName = "hyperion";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;

  # Enable the LXQT Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.lxqt.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  services.printing.enable = true;

  sound.enable = false;

  programs.zsh.enable = true;

  users.users.nmelzer = {
    isNormalUser = true;
    description = "Norbert Melzer";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    packages = [
      # firefox
      #  thunderbird
    ];
  };

  system.stateVersion = "22.11";
}
