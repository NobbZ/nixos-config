{
  config,
  pkgs,
  ...
}: let
  domain = "windmill.mimas.internal.nobbz.dev";
in {
  services.windmill = {
    enable = true;
    package = pkgs.windmill.overrideAttrs (oa: {
      cargoBuildFeatures = oa.cargoBuildFeatures ++ ["run_inline"];
    });
    serverPort = config.lib.nobbz.mimas.ports.windmill;
    baseUrl = "https://${domain}";
    logLevel = "trace";
    # Windmill requires a TCP connection, as it will try reconnect using a
    # different set of users depending on the task
    database.url = "postgresql://windmill:windmill@localhost:5432/windmill";
  };

  services.traefik.dynamicConfigOptions.http.routers.windmill = {
    entryPoints = ["https" "http"];
    rule = "Host(`${domain}`)";
    service = "windmill";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.windmill.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://localhost:${toString config.services.windmill.serverPort}";}];
  };
}
