{
  modulesPath,
  lib,
  ...
}: {
  _file = ./base.nix;

  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
  ];

  isoImage = {
    edition = "nobbz";
    squashfsCompression = "zstd -Xcompression-level 10";
  };

  # VMware guest tools are enabled by default in the installer and caused issues
  # on my Tuxedo laptop.
  virtualisation.vmware.guest.enable = lib.mkForce false;
}
