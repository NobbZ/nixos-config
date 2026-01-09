{
  config,
  pkgs,
  lib,
  ...
}: {
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.mimas.internal.nobbz.lan";
      http_port = 2342;
      http_addr = "127.0.0.1";
    };
  };

  # nginx reverse proxy - required by grafana module
  services.nginx.virtualHosts.${config.services.grafana.domain} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.grafana = {
    entryPoints = ["https" "http"];
    rule = "Host(`grafana.mimas.internal.nobbz.dev`)";
    service = "grafana";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.grafana.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://localhost:${toString config.services.grafana.settings.server.http_port}";}];
  };
}
