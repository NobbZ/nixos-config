{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs) wally-cli;

  cfg = hardware.keyboard.zsa;
in

{
  config = mkIf cfg.enable {
    users.users.nmelzer.extraGroups = [ "plugdev" ];
    environment.systemPackages = [ wally-cli ];
  };
}
