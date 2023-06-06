_: {
  pkgs,
  lib,
  config,
  ...
}: let
  zfsUsed = lib.lists.elem "zfs" (config.boot.supportedFilesystems ++ config.boot.initrd.supportedFilesystems);
in {
  _file = ./kernel.nix;

  boot.kernelPackages = lib.mkDefault (
    if zfsUsed
    then pkgs.zfs.latestCompatibleLinuxPackages
    else pkgs.linuxPackages_latest
  );
}
