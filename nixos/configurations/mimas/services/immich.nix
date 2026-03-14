{
  config,
  lib,
  pkgs,
  ...
}: {
  services.immich = {
    enable = true;
    database.enableVectors = false;
  };

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

  services.monit.config = ''
    check process immich matching "^immich$"
      start program = "${lib.getExe' pkgs.systemd "systemctl"} start immich-server"
      stop program = "${lib.getExe' pkgs.systemd "systemctl"} stop immich-server"

      if failed host immich.mimas.internal.nobbz.dev port 443 protocol https for 4 cycles then restart
      if failed host localhost port ${toString config.services.immich.port} protocol http for 4 cycles then restart
  '';
}
