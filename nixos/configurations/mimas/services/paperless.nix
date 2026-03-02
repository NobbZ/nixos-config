{
  config,
  lib,
  ...
}: let
  services = [
    "paperless-consumer"
    "paperless-scheduler"
    "paperless-task-queue"
    "paperless-web"
  ];

  mount = "var-lib-paperless.mount";
  path = "/var/lib/paperless";

  domain = "paperless.mimas.internal.nobbz.dev";
in {
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    settings.PAPERLESS_OCR_LANGUAGE = "deu+eng";
    settings.PAPERLESS_URL = "https://${domain}";
  };

  systemd.services = lib.genAttrs services (_name: {
    after = [mount];
    wants = [mount];
    unitConfig.RequiresMountsFor = [path];
  });

  services.traefik.dynamicConfigOptions.http.routers.paperless = {
    entryPoints = ["https" "http"];
    rule = "Host(`${domain}`)";
    service = "paperless";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.paperless.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://localhost:${toString config.services.paperless.port}";}];
  };
}
