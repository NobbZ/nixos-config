# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  lib,
  pkgs,
  ...
}: {
  _file = ./mimas.nix;

  imports = [];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = ["dm-snapshot" "i915"];
  boot.kernelModules = ["kvm-intel"];
  boot.kernelParams = ["intel_pstate=active"];
  boot.extraModulePackages = [];
  boot.supportedFilesystems = ["ntfs" "exfat" "avfs" "xfs"];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

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
    device = "/dev/pool/docker";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/var/lib/gitea" = {
    device = "/dev/pool/gitea";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/var/lib/grafana" = {
    device = "/dev/pool/grafana";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/var/lib/prometheus2" = {
    device = "/dev/pool/prometheus";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/var/lib/paperless" = {
    device = "/dev/pool/paperless";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/var/lib/restic" = {
    device = "/dev/usbpool/restic";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/var/lib/ums" = {
    device = "/dev/usbpool/ums";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/var/lib/actual" = {
    device = "/dev/pool/actual";
    fsType = "xfs";
    options = ["nofail"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7000-3A85";
    fsType = "vfat";
  };

  fileSystems."/tmp" = {
    device = "/dev/pool/lvm-tmp";
    fsType = "ext4";
  };

  swapDevices = [];

  nix.settings.max-jobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.graphics.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];
}
