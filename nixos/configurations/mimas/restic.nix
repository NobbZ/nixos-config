{self, ...}: {
  config,
  pkgs,
  lib,
  ...
}: let
  resticPort = 9999;

  inherit (pkgs) writeShellScript proot mount umount restic;

  pools = {
    gitea = "/var/lib/gitea";
    grafana = "/var/lib/grafana";
    paperless = "/var/lib/paperless";
    prometheus = "/var/lib/prometheus2";
  };

  extraPathes = [
    "/var/lib/nixos"
  ];

  fileFromList = pkgs.writeText "files-from-verbatim" ''
    ${lib.concatStringsSep "\n" pathes}
  '';

  basePath = "/tmp/backup";
  pathes = extraPathes ++ builtins.attrValues pools;
  mounts = lib.flatten (lib.mapAttrsToList (lv: path: ["-b" "${basePath}/${lv}:${path}"]) pools);

  snaps = lib.mapAttrs' (lv: _: lib.nameValuePair "${lv}_snap" "pool/${lv}") pools;
  lvcreates = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: origin: "lvcreate -s --name ${name} ${origin}") snaps);
  lvactivates = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "lvchange -ay -Ky pool/${name}") snaps);
  mkdirs = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "mkdir -p ${basePath}/${lv}") pools);
  mountCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "mount -o ro /dev/pool/${lv}_snap ${basePath}/${lv}") pools);

  unmountCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (lv: _: "umount ${basePath}/${lv}") pools);
  lvdeactivates = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "lvs | grep -E '${name}\\s+.*a' || lvchange -an pool/${name}") snaps);
  lvremoves = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "lvs | grep -E '${name}' || lvremove pool/${name}") snaps);

  rest_repo = "rest:https://restic.mimas.internal.nobbz.dev/mimas";
  gdrv_repo = "/home/nmelzer/timmelzer@gmail.com/restic_repos/mimas";
  btwo_repo = "b2:nobbz-restic-services";
  pass = config.sops.secrets.restic.path;

  pre = writeShellScript "restic-services-backup-pre" ''
    set -x

    ${lvdeactivates}
    ${lvremoves}

    ${lvcreates}
    ${lvactivates}

    ${mkdirs}

    ${mountCmds}
  '';

  script = writeShellScript "restic-services-backup" ''
    set -x

    # TODO: Make the latter from snapshots as well!
    proot ${lib.escapeShellArgs mounts} restic --tag services -vv backup --files-from-verbatim ${fileFromList}
  '';

  post = writeShellScript "restic-services-backup-post" ''
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
    preStart = "${pre}";
    script = "${script}";
    postStart = "${post}";
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

  systemd.timers.restic-system-snapshot-sync-and-prune = {
    wantedBy = ["timers.target"];
    timerConfig.OnCalendar = "daily";
  };

  systemd.services.restic-system-snapshot-sync-and-prune = {
    path = [restic];
    after = ["run-secrets.d.mount"];
    serviceConfig.Type = "oneshot";
    serviceConfig.LoadCredential = [
      "b2:${config.sops.secrets.backblaze.path}"
      "pass:${pass}"
    ];
    script = ''
      eval $(cat "$CREDENTIALS_DIRECTORY/b2")

      restic copy --repo ${rest_repo} --repo2 ${gdrv_repo} -vvv
      restic copy --repo ${rest_repo} --repo2 ${btwo_repo} -vvv

      restic forget --repo ${rest_repo} --keep-hourly 12 --keep-daily 4 --keep-weekly 3 --keep-monthly 7 --keep-yearly 10
      restic forget --repo ${gdrv_repo} --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 20
      restic forget --repo ${btwo_repo} --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 20

      restic prune --repo ${rest_repo} --max-unused 0
      restic prune --repo ${gdrv_repo} --max-unused 0
      restic prune --repo ${btwo_repo}

      chown -Rv nmelzer:users /home/nmelzer/timmelzer@gmail.com/restic_repos
    '';
    environment = {
      RESTIC_PASSWORD_FILE = "%d/pass";
      RESTIC_PASSWORD_FILE2 = "%d/pass";
      RESTIC_COMPRESSION = "max";
      XDG_CACHE_HOME = "%C";
    };
  };
}
