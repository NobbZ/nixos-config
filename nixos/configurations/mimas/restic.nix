_: {...}: let
  resticPort = 9999;
in {
  services.restic.server = {
    enable = true;
    prometheus = true;
    extraFlags = ["--no-auth"]; # This is fine, as we are only reachable through VPN
    listenAddress = "127.0.0.1:${toString resticPort}";
  };

  # We have an extra mount to put restic data on, we need to make sure it is properly
  # mounted before writing anything to it
  systemd.services.restic-rest-server.after = ["var-lib-restic.mount"];

  # Add an appropriate router for traefik
  services.traefik.dynamicConfigOptions.http.routers.restic = {
    entryPoints = ["https" "http"];
    rule = "Host(`restic.mimas.internal.nobbz.dev`)";
    service = "restic";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  # And the service configuration
  services.traefik.dynamicConfigOptions.http.services.restic.loadBalancer = {
    passHostHeader = false;
    servers = [{url = "http://127.0.0.1:${toString resticPort}";}];
  };
}
