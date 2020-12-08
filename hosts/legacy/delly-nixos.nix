# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [ ];

  nix.useSandbox = false;
  nix.autoOptimiseStore = true;
  nix.buildCores = 1;
  nix.gc.automatic = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.useOSProber = true;

  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  boot.blacklistedKernelModules = [ "rtl8xxxu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8192eu
  ];
  boot.supportedFilesystems = [ "zfs" "ntfs-3g" ];

  # boot.kernelPackages = pkgs.linuxPackages_4_19;
  boot.kernel.sysctl = {
    "vm.swappiness" = 75;
  };

  networking.hostName = "delly-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [
    "mac:0c:60:76:3f:c1:31"
  ];
  networking.enableB43Firmware = true;

  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;
  networking.hostId = "62a007d6"; # required by ZFS

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    emacs
    firefox
    rsync
    chromium
    git
    gparted
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e";

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "8286ac0e4768c8ae" ];

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.windowManager.awesome.enable = true;

  # services.kbfs.enable = true;
  # services.keybase.enable = true;

  virtualisation = {
    docker = {
      enable = true;
    };

    # virtualbox.host.enable = true;
  };

  programs.gc.enable = true;
  programs.gc.maxAge = "30d";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    nmelzer = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" "adbusers" ]; # Enable ‘sudo’ for the user.
    };
    aroemer = {
      isNormalUser = true;
    };
    proemer = {
      isNormalUser = true;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
