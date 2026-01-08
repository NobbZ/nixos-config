_: {config, ...}: let
  host = "passwords.mimas.internal.nobbz.dev";
  wardenPort = 10000;
in {
  sops.secrets.warden = {};

  services.vaultwarden = {
    enable = true;
    environmentFile = config.sops.secrets.warden.path;
    config = {
      DOMAIN = "https://${host}";
      DATABASE_MAX_CONNS = "5";

      # LOG_LEVEL = "debug";

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = "${toString wardenPort}";
      ROCKET_WORKERS = "5";
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.warden = {
    entryPoints = ["https" "http"];
    rule = "Host(`${host}`)";
    service = "vaultwarden";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.vaultwarden.loadBalancer = {
    passHostHeader = false;
    servers = [{url = "http://127.0.0.1:${toString wardenPort}";}];
  };
}
