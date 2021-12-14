{ config, lib, ... }:

let
  cfg = config.services.k3s;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall.trustedInterfaces = [ "cni0" ];
  };
}
