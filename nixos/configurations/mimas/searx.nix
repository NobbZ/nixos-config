_inputs: {config, pkgs, ...}: {
  sops.secrets.searx = {};

  services.searx = {
    enable = true;

    package = pkgs.searxng;

    domain = "search.mimas.internal.nobbz.dev";

    environmentFile = config.sops.secrets.searx.path;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.searx = {
      entrypoints = ["http" "https"];
      rule = "Host(`${config.services.searx.domain}`)";
      service = "searx";
      tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
      tls.certResolver = "mimasWildcard";
    };

    services.searx = {
      loadBalancer.passHostHeader = true;
      loadBalancer.servers = [{url = "http://localhost:8888";}];
    };
  };
}
