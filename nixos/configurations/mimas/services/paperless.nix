_: {config, ...}: {
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    settings.PAPERLESS_OCR_LANGUAGE = "deu+eng";
  };

  systemd.services.paperless-consumer.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-scheduler.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-task-queue.after = ["var-lib-paperless.mount"];
  systemd.services.paperless-web.after = ["var-lib-paperless.mount"];

  services.traefik.dynamicConfigOptions.http.routers.paperless = {
    entryPoints = ["https" "http"];
    rule = "Host(`paperless.mimas.internal.nobbz.dev`)";
    service = "paperless";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.paperless.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://localhost:${toString config.services.paperless.port}";}];
  };
}
