{
  config,
  pkgs,
  ...
}: {
  services.immich = {
    enable = true;
    database.enableVectors = false;
  };

  services.postgresql.package = pkgs.postgresql_18;
  systemd.services.immich-server = {
    after = ["var-lib-immich.mount"];
    wants = ["var-lib-immich.mount"];
    unitConfig.RequiresMountsFor = ["/var/lib/immich"];
  };

  services.traefik.dynamicConfigOptions.http.routers.immich = {
    entryPoints = ["https" "http"];
    rule = "Host(`immich.mimas.internal.nobbz.dev`)";
    service = "immich";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.immich.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://localhost:${toString config.services.immich.port}";}];
  };
}
