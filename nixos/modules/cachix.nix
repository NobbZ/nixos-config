{ config, pkgs, lib, ... }:
let
  folder = ./cachix;
  toImport = name: value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
  imports = lib.mapAttrsToList toImport (lib.filterAttrs filterCaches (builtins.readDir folder));
in
{
  inherit imports;
  nix.binaryCaches = lib.mkDefault (lib.optional (config.networking.hostName != "delly-nixos") "https://cache.nixos.org/");

  environment.systemPackages = [ pkgs.cachix ];
}
