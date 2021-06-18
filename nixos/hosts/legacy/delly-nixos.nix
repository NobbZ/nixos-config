# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.contentAddressedByDefault = true;

  nixpkgs.overlays = [
    (final: prev: {
      SDL = with prev; prev.SDL.overrideAttrs(o: {
        patches = [
          # "${prev.pkgs}/pkgs/development/libraries/SDL/find-headers.patch"
          "${builtins.head o.patches}"

          # Fix window resizing issues, e.g. for xmonad
          # Ticket: http://bugzilla.libsdl.org/show_bug.cgi?id=1430
          (fetchpatch {
            name = "fix_window_resizing.diff";
            url = "https://bugs.debian.org/cgi-bin/bugreport.cgi?msg=10;filename=fix_window_resizing.diff;att=2;bug=66
5779";
            sha256 = "1z35azc73vvi19pzi6byck31132a8w1vzrghp1x3hy4a4f9z4gc6";
          })
          # Fix drops of keyboard events for SDL_EnableUNICODE
          (fetchpatch {
            url = "https://github.com/libsdl-org/SDL-1.2/commit/0332e2bb18dc68d6892c3b653b2547afe323854b.patch";
            sha256 = "sha256-5V6K0oTN56RRi48XLPQsjgLzt0a6GsjajDrda3ZEhTw=";
          })
          # Ignore insane joystick axis events
          (fetchpatch {
            url = "https://github.com/libsdl-org/SDL-1.2/commit/ab99cc82b0a898ad528d46fa128b649a220a94f4.patch";
            sha256 = "sha256-uussXT9Spsg8WUX5CNHZ6HthYy3HE381xi03Ygv3hwU=";
          })
          # https://bugzilla.libsdl.org/show_bug.cgi?id=1769
          (fetchpatch {
            url = "https://github.com/libsdl-org/SDL-1.2/commit/5d79977ec7a6b58afa6e4817035aaaba186f7e9f.patch";
            sha256 = "sha256-JvMP7+P/NmWLNsCGfElDLdlA99Nbggw+5jskD572fXU=";
          })
          # Workaround X11 bug to allow changing gamma
          # Ticket: https://bugs.freedesktop.org/show_bug.cgi?id=27222
          (fetchpatch {
            name = "SDL_SetGamma.patch";
            url = "https://src.fedoraproject.org/cgit/rpms/SDL.git/plain/SDL-1.2.15-x11-Bypass-SetGammaRamp-when-chang
ing-gamma.patch?id=04a3a7b1bd88c2d5502292fad27e0e02d084698d";
            sha256 = "0x52s4328kilyq43i7psqkqg7chsfwh0aawr50j566nzd7j51dlv";
          })
          # Fix a build failure on OS X Mavericks
          # Ticket: https://bugzilla.libsdl.org/show_bug.cgi?id=2085
          (fetchpatch {
            url = "https://github.com/libsdl-org/SDL-1.2/commit/19039324be71738d8990e91b9ba341b2ea068445.patch";
            sha256 = "sha256-CPcLE+8JMKoiJEdIWNVphIMIgDOIJBmkSNO1zuM97B8=";
          })
          (fetchpatch {
            url = "https://github.com/libsdl-org/SDL-1.2/commit/7933032ad4d57c24f2230db29f67eb7d21bb5654.patch";
            sha256 = "sha256-6CdDVsrka8zlqFrZ2SCo62DuiSWiGJIfLi/rMX2v0W4=";
          })
        ];
      });
    })
  ];

  imports = [ ];

  # nix.useSandbox = false;
  nix.autoOptimiseStore = true;
  nix.buildCores = 1;
  nix.maxJobs = 2;
  # nix.gc.automatic = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.useOSProber = false;

  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  boot.kernelPackages = pkgs.linuxPackages_5_4;
  boot.blacklistedKernelModules = [ "rtl8xxxu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8192eu
  ];
  boot.supportedFilesystems = []; # "zfs" "ntfs-3g" ];

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
  networking.interfaces.enp0s25.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = false;
  networking.hostId = "62a007d6"; # required by ZFS

  # hardware.opengl.driSupport32Bit = true;
  # hardware.pulseaudio.support32Bit = true;

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
    rsync
    git
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
  services.xserver.desktopManager.plasma5.enable = false;
  services.xserver.windowManager.awesome.enable = true;

  # services.kbfs.enable = true;
  # services.keybase.enable = true;

  virtualisation = {
    docker = {
      enable = false;
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
