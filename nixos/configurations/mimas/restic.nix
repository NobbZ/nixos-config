_: {
  config,
  pkgs,
  lib,
  ...
}: let
  resticPort = 9999;

  inherit (pkgs) writeShellScript proot restic mount umount;

  pools = {
    docker = "/var/lib/docker";
    gitea = "/var/lib/gitea";
    grafana = "/var/lib/grafana";
    paperless = "/var/lib/paperless";
    prometheus = "/var/lib/prometheus2";
  };

  basePath = "/tmp/backup";
  pathes = builtins.attrValues pools;
  mounts = lib.flatten (lib.mapAttrsToList (lv: path: ["-b" "${basePath}/${lv}:${path}"]) pools);

  snaps = lib.mapAttrs' (lv: _: lib.nameValuePair "${lv}_snap" "pool/${lv}") pools;
  lvcreates = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: origin: "lvcreate -s --name ${name} ${origin}") snaps);
  lvchanges = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "lvchange -ay -Ky pool/${name}") snaps);
  mkdirs = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "mkdir -p ${basePath}/${lv}") pools);
  mountCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "mount -o ro /dev/pool/${lv}_snap ${basePath}/${lv}") pools);

  unmountCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "umount ${basePath}/${lv}") pools);
  lvunchanges = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "lvchange -an pool/${name}") snaps);
  lvremoves = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: origin: "lvremove pool/${name}") snaps);

  repo = "rest:https://restic.mimas.internal.nobbz.dev/mimas";
  pass = "/home/nmelzer/.config/restic/password";

  script = writeShellScript "restic-services-backup" ''
    set -ex

    # Create the snapshots
    ${lvcreates}
    ${lvchanges}
    ${mkdirs}
    ${mountCmds}

    # TODO: Make the latter from snapshots as well!
    proot ${lib.escapeShellArgs mounts} restic --tag services -vv backup ${lib.escapeShellArgs pathes}

    ${unmountCmds}
    ${lvunchanges}
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

  systemd.timers.restic-system-snapshot-backup = {
    wantedBy = ["timers.target"];
    timerConfig.OnCalendar = "hourly";
  };

  systemd.services.restic-system-snapshot-backup = {
    path = [proot restic mount umount config.services.lvm.package];
    script = "${script}";
    environment = {
      RESTIC_REPOSITORY = "rest:https://restic.mimas.internal.nobbz.dev/mimas";
      RESTIC_PASSWORD_FILE = "/home/nmelzer/.config/restic/password";
    };
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.timers.restic-system-snapshot-sync-and-prune = {
    wantedBy = ["timers.target"];
    timerConfig.OnCalendar = "daily";
  };

  systemd.services.restic-system-snapshot-sync-and-prune = {
    path = [restic];
    serviceConfig.Type = "oneshot";
    serviceConfig.LoadCredential = [
      "b2:/home/nmelzer/.config/restic/b2"
    ];
    script = ''
      eval $(cat "$CREDENTIALS_DIRECTORY/b2")

      restic copy --repo rest:https://restic.mimas.internal.nobbz.dev/mimas --repo2 /home/nmelzer/timmelzer@gmail.com/restic_repos/mimas -vvv
      restic copy --repo rest:https://restic.mimas.internal.nobbz.dev/mimas --repo2 b2:nobbz-restic-services -vvv

      restic forget --repo rest:https://restic.mimas.internal.nobbz.dev/mimas --keep-hourly 12 --keep-daily 4 --keep-weekly 3 --keep-monthly 7 --keep-yearly 10
      restic forget --repo /home/nmelzer/timmelzer@gmail.com/restic_repos/mimas --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 20
      restic forget --repo b2:nobbz-restic-services --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 20

      restic prune --repo rest:https://restic.mimas.internal.nobbz.dev/mimas --max-unused 0
      restic prune --repo /home/nmelzer/timmelzer@gmail.com/restic_repos/mimas --max-unused 0
      restic prune --repo b2:nobbz-restic-services

      chown -Rv nmelzer:users /home/nmelzer/timmelzer@gmail.com/restic_repos
    '';
    environment = {
      RESTIC_PASSWORD_FILE = "/home/nmelzer/.config/restic/password";
      RESTIC_PASSWORD_FILE2 = "/home/nmelzer/.config/restic/password";
      XDG_CACHE_HOME = "%C";
    };
  };
}