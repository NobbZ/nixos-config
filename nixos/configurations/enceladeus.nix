# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
_: {
  config,
  pkgs,
  lib,
  ...
}: {
  _file = ./enceladeus.nix;

  nix.allowedUnfree = ["b43-firmware" "zerotierone"];
  nixpkgs.config.contentAddressedByDefault = false;
  nix.distributedBuilds = true;
  # nix.enabledMachines = ["mimas"];

  # nixpkgs.hostPlatform.gcc.arch = "core2";
  # nixpkgs.hostPlatform.system = "x86_64-linux";
  # nixpkgs.buildPlatform.gcc.arch = "haswell";
  # nixpkgs.buildPlatform.system = "x86_64-linux";

  nixpkgs.overlays = [
    # (final: prev: {
    #   abseil-cpp = nixpkgs.legacyPackages.${final.system}.abseil-cpp;
    #   #bash = prev.bash.override { stdenv = nixpkgs.legacyPackages.${final.system}.stdenv; };
    # })
  ];

  services.lvm.boot.thin.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_6_6; # TODO: Figure why I have this and nothing newer?
  services.lvm.dmeventd.enable = true;
  boot.blacklistedKernelModules = ["rtl8xxxu"];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8192eu
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 75;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [
    "mac:0c:60:76:3f:c1:31"
  ];
  networking.enableB43Firmware = true;

  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = false;
  networking.hostId = "62a007d6"; # required by ZFS

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
    unison # Sadly required on the host for unison copy to work :(
    nix-output-monitor
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.zsh.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [9002];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.trustedInterfaces = [
    "ztrta4jrxj"
  ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.plasma5.enable = false;
  services.xserver.windowManager.awesome.enable = true;

  virtualisation.docker.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    nmelzer = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = ["wheel" "networkmanager"];
    };

    aroemer = {
      isNormalUser = true;
    };

    proemer = {
      isNormalUser = true;
    };
  };

  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        port = 9002;
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

  security.sudo.extraRules = [
    {
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
      ];
      groups = ["wheel"];
    }
  ];
}
