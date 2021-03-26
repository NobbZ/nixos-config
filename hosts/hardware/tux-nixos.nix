# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "rpool/safe/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "rpool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/var/lib/transmission" = {
    device = "rpool/local/transmission";
    fsType = "zfs";
  };

  fileSystems."/home" =
    {
      device = "rpool/safe/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/27F3-0DEA";
      fsType = "vfat";
    };

  fileSystems."/home/aroemer" =
    {
      device = "rpool/safe/home/aroemer";
      fsType = "zfs";
    };

  fileSystems."/home/nmelzer" =
    {
      device = "rpool/safe/home/nmelzer";
      fsType = "zfs";
    };

  swapDevices =
    [
      { device = "/dev/disk/by-uuid/9fc8f2be-fbbc-4ae1-b171-5f26facd6a29"; }
    ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
