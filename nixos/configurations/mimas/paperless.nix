{master, ...}: {config, ...}: {
  services.paperless = {
    enable = true;
    # Please watch for the following to be resolved, then remove the package
    # * https://github.com/NixOS/nixpkgs/issues/207965
    # * https://github.com/NixOS/nixpkgs/pull/207754
    # * https://nixpk.gs/pr-tracker.html?pr=207754
    package = master.legacyPackages.x86_64-linux.paperless-ngx;
    address = "0.0.0.0";
    port = 58080;
    extraConfig.PAPERLESS_OCR_LANGUAGE = "deu+eng";
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
