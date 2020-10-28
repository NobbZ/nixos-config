{ config, pkgs, ... }:

let
  vboxpkgs = pkgs.fetchFromGitHub {
    owner = "bachp";
    repo = "nixpkgs";
    rev = "aaf75813cd7599c5e0939d5ac905cc281ab6e7db";
    sha256 = pkgs.lib.fakeSha256;
  };
in
{
  imports = [
    # <nixpkgs/nixos/modules/installer/virtualbox-demo.nix>
  ];

  nixpkgs.overlays = [
    (self: super: {
      virtualboxGuestAdditions = self.callPackage (vboxpkgs.outPath + "/pkgs/applications/virtualization/virtualbox/guest-additions") {};
    })
  ];
  nixpkgs.config.allowUnfree = true;

  users.users.demo =
    { isNormalUser = true;
      description = "Demo user account";
      extraGroups = [ "wheel" "docker" ];
      uid = 1000;
      shell = pkgs.zsh;
      # home = "/home/nmelzer";
    };

  boot.kernel.sysctl = {
    "vm.max_map_count" = 262144;
  };

  programs.zsh.enable = true;

  nix.useSandbox = true;
  nix.autoOptimiseStore = true;
  # nix.package = pkgs.nixUnstable;
  # nix.extraOptions = ''
  #   experimental-features = nix-command flakes
  # '';

  virtualisation = {
    docker.enable = true;
    docker.extraOptions = "--insecure-registry registry.cap01.cloudseeds.de";
  };

  console.font = "Lat2-Terminus16";
  console.keyMap = "de";

  services.xserver.layout = pkgs.lib.mkForce "de";

  services.xserver.videoDrivers = [ "vmware" "virtualbox" "modesetting" ];
  systemd.services.virtualbox-resize = {
    description = "VirtualBox Guest Screen Resizing";

    wantedBy = [ "multi-user.target" ];
    requires = [ "dev-vboxguest.device" ];
    after = [ "dev-vboxguest.device" ];

    unitConfig.ConditionVirtualization = "oracle";

    serviceConfig.ExecStart = "@${config.boot.kernelPackages.virtualboxGuestAdditions}/bin/VBoxClient -fv --vmsvga";
  };

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "8286ac0e4768c8ae" ];

  # Let demo build as a trusted user.
# nix.trustedUsers = [ "demo" ];

# Mount a VirtualBox shared folder.
# This is configurable in the VirtualBox menu at
# Machine / Settings / Shared Folders.
# fileSystems."/mnt" = {
#   fsType = "vboxsf";
#   device = "nameofdevicetomount";
#   options = [ "rw" ];
# };

# By default, the NixOS VirtualBox demo image includes SDDM and Plasma.
# If you prefer another desktop manager or display manager, you may want
# to disable the default.
# services.xserver.desktopManager.plasma5.enable = lib.mkForce false;
# services.xserver.displayManager.sddm.enable = lib.mkForce false;

# Enable GDM/GNOME by uncommenting above two lines and two lines below.
# services.xserver.displayManager.gdm.enable = true;
# services.xserver.desktopManager.gnome3.enable = true;

# Set your time zone.
# time.timeZone = "Europe/Amsterdam";

# List packages installed in system profile. To search, run:
# \$ nix search wget
  # environment.systemPackages = with pkgs; [
  #   nixFlakes
  # ];

# Enable the OpenSSH daemon.
  services.openssh.enable = true;

  swapDevices = [{
    device = "/var/swap-2";
    size = 2048 * 4;
  }];

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "builder-zerotier";
      system = "x86_64-linux";
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
}
