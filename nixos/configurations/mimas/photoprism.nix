_: {
  config,
  lib,
  ...
}: {
  _file = ./photoprism.nix;

  services.photoprism = {
    enable = true;

    port = 2343;
    # address = "photos.mimas.internal.nobbz.dev";
    address = "localhost";

    settings = {
      PHOTOPRISM_ORIGINALS_LIMIT = "-1";
      PHOTOPRISM_RESOLUTION_LIMIT = "-1";
    };

    passwordFile = "${config.sops.secrets.photoprismAdmin.path}";

    storagePath = "/var/lib/photoprism";
    originalsPath = "${config.services.photoprism.storagePath}/originals";
  };

  systemd.services.photoprism.after = ["var-lib-pool\x2dphotoprism.mount"];
  # systemd.services.photoprism.serviceConfig.DynamicUser = lib.mkForce false;
  systemd.services.photoprism.serviceConfig.BindPaths = [
    "/var/lib/pool-photoprism:/var/lib/pool-photoprism"
  ];

  services.traefik.dynamicConfigOptions.http.routers.photoprism = {
    entryPoints = ["http" "https"];
    # rule = "Host(`${config.services.photoprism.address}`)";
    rule = "Host(`photos.mimas.internal.nobbz.dev`)";
    service = "photoprism";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.photoprism.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://localhost:${toString config.services.photoprism.port}";}];
  };

  sops.secrets.photoprismAdmin = {};
}
