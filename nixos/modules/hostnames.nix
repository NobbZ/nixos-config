{ config, lib, pkgs, ... }:

let
  inherit (config.lib.nobbz) hostnames;

  kv = lib.attrsets.nameValuePair;

  hosts = lib.mapAttrs' (name: ip: kv ip ([ name "${name}.nobbz.lan" ])) hostnames;
in
{
  lib.nobbz.hostnames = {
    mimas = "172.24.152.168";
    thetys = "172.24.231.199";
    enceladeus = "172.24.199.101";
  };

  networking.hosts = hosts;
}
