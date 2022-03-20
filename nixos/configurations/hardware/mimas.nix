# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = ["dm-snapshot" "i915"];
  boot.kernelModules = ["kvm-intel"];
  boot.kernelParams = ["intel_pstate=active"];
  boot.extraModulePackages = [];
  boot.supportedFilesystems = ["ntfs" "exfat" "avfs"];

  hardware.cpu.intel.updateMicrocode = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/440c8ce1-1799-4239-936f-a54c879941a5";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/8119ca17-576f-49a2-9496-946d6759a59b";
    fsType = "ext4";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/48574e4d-3a82-4b04-ac28-d55c32fa3aff";
    fsType = "ext4";
  };

  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-uuid/5da6b8c1-2598-48f1-9541-49c50e95aac9";
    fsType = "ext4";
  };

  fileSystems."/var/lib/grafana" = {
    device = "/dev/disk/by-uuid/c6294dc0-f2cb-432b-a993-02d21855732c";
    fsType = "ext4";
  };

  fileSystems."/var/lib/prometheus2" = {
    device = "/dev/disk/by-uuid/3ec5c5b2-d7cd-4b59-bb6b-d1fc40100662";
    fsType = "ext4";
  };

  fileSystems."/var/lib/paperless" = {
    device = "/dev/disk/by-label/paperless";
    fsType = "ext4";
  };

  #  fileSystems."/var/lib/restic" = {
  #    device = "/dev/disk/by-uuid/3eb6492a-b126-4ad5-b9df-4eb47df1135c";
  #    fsType = "ext4";
  #  };

  #  fileSystems."/var/lib/ums" = {
  #    device = "/dev/disk/by-label/ums";
  #    fsType = "ext4";
  #  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7000-3A85";
    fsType = "vfat";
  };

  swapDevices = [];

  nix.settings.max-jobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];
}
