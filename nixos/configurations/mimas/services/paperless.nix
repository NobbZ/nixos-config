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
in {
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    settings.PAPERLESS_OCR_LANGUAGE = "deu+eng";
  };

  systemd.services = lib.genAttrs services (_name: {
    after = [mount];
    wants = [mount];
    unitConfig.RequiresMountsFor = [path];
  });

  services.traefik.dynamic.files.paperless.settings.http = {
    routers.paperless = {
      entryPoints = ["https" "http"];
      rule = "Host(`paperless.mimas.internal.nobbz.dev`)";
      service = "paperless";
      tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
      tls.certResolver = "mimasWildcard";
    };

    services.paperless.loadBalancer = {
      passHostHeader = true;
      servers = [{url = "http://localhost:${toString config.services.paperless.port}";}];
    };
  };
}
