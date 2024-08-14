_: {
  config,
  lib,
  ...
}: let
  cfg = config.services.actual;
  fqdn = "${config.networking.hostName}.${config.networking.domain}";
in {
  options = {
    services.actual = {
      enable = lib.mkEnableOption "actual budget" // {default = true;};

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 5006;
      };

      serviceName = lib.mkOption {
        type = lib.types.str;
        default = "actual";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.actual = {
      image = "ghcr.io/actualbudget/actual-server:24.8.0@sha256:cbdc8d5bd612593d552e8f2e5f05fa959040a924ded6a56d123c51ca6c571337";
      ports = ["${cfg.address}:${toString cfg.port}:5006"];
      volumes = [
        "/var/lib/actual:/data"
      ];
    };

    systemd.services.docker-actual.after = ["var-lib-actual.mount"];

    services.traefik.dynamicConfigOptions.http.routers.actual = {
      entrypoints = ["http" "https"];
      rule = "Host(`${cfg.serviceName}.${fqdn}`)";
      service = "actual";
      tls.domains = [{main = "*.${fqdn}";}];
      tls.certResolver = "mimasWildcard";
    };

    services.traefik.dynamicConfigOptions.http.services.actual.loadBalancer = {
      passHostHeader = true;
      servers = [{url = "http://${cfg.address}:${toString cfg.port}";}];
    };
  };
}
