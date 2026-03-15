{config, ...}: {
  services.dawarich = {
    enable = true;
    localDomain = "dawarich.mimas.internal.nobbz.dev";
    webPort = 3001;
    configureNginx = false;
  };

  services.dawarich.environment = {
    PHOTON_API_HOST = "photon.komoot.io";
    PHOTON_API_USE_HTTPS = "true";
  };

  systemd.services.dawarich-web.unitConfig.RequiresMountsFor = ["/var/lib/dawarich"];

  services.postgresql.ensureDatabases = ["dawarich"];
  services.postgresql.ensureUsers = [
    {
      name = "dawarich";
      ensureDBOwnership = true;
    }
  ];

  services.traefik.dynamicConfigOptions.http.routers.dawarich = {
    entryPoints = ["https" "http"];
    rule = "Host(`${config.services.dawarich.localDomain}`)";
    service = "dawarich";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.dawarich.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://localhost:${toString config.services.dawarich.webPort}";}];
  };
}
