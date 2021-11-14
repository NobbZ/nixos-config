{ config, lib, pkgs, ... }:

let
  cfg = config.services.zerotier;
in
{
  config = lib.mkIf cfg.enable { };
}
