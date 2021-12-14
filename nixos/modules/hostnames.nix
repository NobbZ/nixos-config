{ config, lib, pkgs, ... }:

let
  inherit (config.lib.nobbz) hostnames;

  kv = lib.attrsets.nameValuePair;

  hosts = lib.mapAttrs' (name: ip: kv ip ([ name "${name}.nobbz.lan" ])) hostnames;

  kubenames = [
    "minio.k3os.nobbz.lan"
    "nexus.k3os.nobbz.lan"
    "docker.k3os.nobbz.lan"
    "argo.k3os.nobbz.lan"
  ];
in
{
  lib.nobbz.hostnames = {
    thetys = "172.24.231.199";
    enceladeus = "172.24.199.101";
  };

  networking.hosts = hosts // {
    "192.168.122.122" = kubenames;
    "172.24.152.168" = [ "mimas" "mimas.nobbz.lan" ];
  };
}
