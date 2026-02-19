{self, ...}: {
  config,
  pkgs,
  lib,
  ...
}: let
  resticPort = 9999;

  inherit (pkgs) proot mount umount restic;

  pools = {
    gitea = "/var/lib/gitea";
    grafana = "/var/lib/grafana";
    paperless = "/var/lib/paperless";
    prometheus = "/var/lib/prometheus2";
  };

  extraPathes = [
    "/var/lib/nixos"
    "/var/lib/redis-paperless"
  ];

  basePath = "/tmp/backup";
  mounts = lib.flatten (
    (lib.mapAttrsToList (lv: path: ["-b" "${basePath}/${lv}:${path}"]) pools)
    ++ (builtins.map (path: ["-b" "${path}:${path}"]) extraPathes)
  );

  snaps = lib.mapAttrs' (lv: _: lib.nameValuePair "${lv}_snap" "pool/${lv}") pools;
  lvcreates = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: origin: "lvcreate -s --name ${name} ${origin}") snaps);
  lvactivates = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "lvchange -ay -Ky pool/${name}") snaps);
  mkdirs = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "mkdir -p ${basePath}/${lv}") pools);
  mountCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "mount -o ro /dev/pool/${lv}_snap ${basePath}/${lv}") pools);

  unmountCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "umount ${basePath}/${lv}") pools);
  uncheckedUnmountCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "umount ${basePath}/${lv} || true") pools);
  lvdeactivates = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "lvs | grep -E '${name}\\s+.*a' && lvchange -an pool/${name}") snaps);
  lvremoves = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "lvs | grep -E '${name}' && lvremove pool/${name}") snaps);

  rest_repo = "rest:https://restic.mimas.internal.nobbz.dev/mimas";
  pass = config.sops.secrets.restic.path;

  preStart = ''
    set -x

    ${uncheckedUnmountCmds}

    ${lvdeactivates}
    ${lvremoves}

    ${lvcreates}
    ${lvactivates}

    ${mkdirs}

    ${mountCmds}

    /run/wrappers/bin/sudo -u vaultwarden ${pkgs.sqlite}/bin/sqlite3 /var/lib/bitwarden_rs/db.sqlite3 .dump > /var/lib/bitwarden_rs/dump.sql
  '';

  script = ''
    set -x

    # TODO: Make the latter from snapshots as well!
    proot ${lib.escapeShellArgs mounts} \
      -b /var/lib/bitwarden_rs:/var/lib/bitwarden_rs \
      -b /nix:/nix \
      -b ''${CREDENTIALS_DIRECTORY}:''${CREDENTIALS_DIRECTORY} \
      -b /etc:/etc \
      -b /tmp:/tmp \
      -r /var/empty \
      restic --tag services -vv backup /var/lib
  '';

  postStart = ''
    set -x

    ${unmountCmds}

    ${lvdeactivates}
    ${lvremoves}

    rm -rfv ${basePath}
  '';
in {
  services.restic.server = {
    enable = true;
    prometheus = true;
    extraFlags = ["--no-auth"]; # This is fine, as we are only reachable through VPN
    listenAddress = "127.0.0.1:${toString resticPort}";
  };

  systemd.services.restic-rest-server = {
    # We have an extra mount to put restic data on, we need to make sure it is properly
    # mounted before writing anything to it
    after = ["var-lib-restic.mount"];
    wants = ["var-lib-restic.mount"];
    unitConfig.RequiresMountsFor = ["/var/lib/restic"];
  };

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

  systemd.timers.restic-system-snapshot-backup = {
    wantedBy = ["timers.target"];
    timerConfig.OnCalendar = "hourly";
  };

  systemd.services.restic-system-snapshot-backup = {
    inherit preStart script postStart;
    path = [proot restic mount umount config.services.lvm.package];
    serviceConfig.LoadCredential = ["pass:${pass}"];
    environment = {
      RESTIC_REPOSITORY = rest_repo;
      RESTIC_PASSWORD_FILE = "%d/pass";
      RESTIC_COMPRESSION = "max";
    };
    serviceConfig = {
      Type = "oneshot";
    };
  };
}
