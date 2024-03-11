_: {pkgs, ...}: {
  _file = ./hyperion.nix;

  nix.allowedUnfree = ["zerotierone"];

  networking.hostName = "hyperion";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;

  # Enable the LXQT Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.lxqt.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.enlightenment.enable = true;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  services.openssh.enable = true;

  services.acpid.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  services.printing.enable = true;

  programs.zsh.enable = true;

  users.users.nmelzer = {
    isNormalUser = true;
    description = "Norbert Melzer";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    packages = [
      pkgs.firefox
      #  thunderbird
    ];
  };

  system.stateVersion = "22.11";
}
