{
  config,
  pkgs,
  lib,
  ...
}: let
  profile_name = template: lib.removeSuffix ".toml" config.sops.templates."${template}".path;

  environment = {
    RUSTIC_NO_PROGRESS = "true";
    RUSTIC_CACHE_DIR = "%T/rustic";
  };

  mimas_template =
    # toml
    ''
      [repository]
      repository = "rest:https://restic.mimas.internal.nobbz.dev/mimas"
      password-file = "${config.sops.secrets.rustic.path}"

      [copy]
      targets = ["${profile_name "mimas_hetzner.toml"}"]
    '';
  mimas_hetzner_template =
    # toml
    ''
      [repository]
      repository = "opendal:sftp"
      password-file = "${config.sops.secrets.rustic.path}"

      [repository.options]
      endpoint = "ssh://${config.sops.placeholder.rustic-user}.your-storagebox.de:23"
      user = "${config.sops.placeholder.rustic-user}"
      key = "/root/.ssh/id_ed25519"
      root = "/home/mimas"
    '';

  nobbz_template =
    # toml
    ''
      [repository]
      repository = "rest:https://restic.mimas.internal.nobbz.dev/nobbz"
      password-file = "${config.sops.secrets.rustic.path}"

      [copy]
      targets = ["${profile_name "nobbz_hetzner.toml"}"]
    '';

  nobbz_hetzner_template =
    # toml
    ''
      [repository]
      repository = "opendal:sftp"
      password-file = "${config.sops.secrets.rustic.path}"

      [repository.options]
      endpoint = "ssh://${config.sops.placeholder.rustic-user}.your-storagebox.de:23"
      user = "${config.sops.placeholder.rustic-user}"
      key = "/root/.ssh/id_ed25519"
      root = "/home/nobbz"
    '';

  schedule = {
    rustic-mimas-clean = "*-*-* 01:00:00";
    rustic-nobbz-clean = "*-*-* 01:30:00";
    rustic-mimas-hetzner-clean = "*-*-* 02:00:00";
    rustic-nobbz-hetzner-clean = "*-*-* 03:00:00";
  };

  mkTimer = name: calendar: {
    "${name}" = {
      wantedBy = ["timers.target"];
      timerConfig.OnCalendar = calendar;
    };
  };

  notify = lib.getExe' pkgs.systemd "systemd-notify";
in {
  sops.secrets.rustic = {};
  sops.secrets.rustic-user = {};

  sops.templates."mimas.toml".content = mimas_template;
  sops.templates."mimas_hetzner.toml".content = mimas_hetzner_template;
  sops.templates."nobbz.toml".content = nobbz_template;
  sops.templates."nobbz_hetzner.toml".content = nobbz_hetzner_template;

  systemd.timers = lib.pipe schedule [
    (lib.mapAttrsToList mkTimer)
    lib.mkMerge
  ];

  systemd.services = {
    rustic-mimas-clean = {
      path = [pkgs.rustic pkgs.openssh];
      inherit environment;
      serviceConfig = {
        NotifyAccess = "all";
        Type = "notify";
      };
      script = ''
        ${notify} --ready
        ${notify} --status=forget
        rustic forget -P ${profile_name "mimas.toml"} \
          --keep-last 4 \
          --keep-within-hourly 1d \
          --keep-within-daily 5d \
          --keep-within-weekly 35d \
          --keep-within-monthly 100d \
          --keep-within-yearly 2y

        ${notify} --status=prune
        rustic prune -P ${profile_name "mimas.toml"} \
          --max-unused=0B \
          --keep-delete=12h \
          --max-repack=50GiB

        ${notify} --status=copy
        rustic copy -P ${profile_name "mimas.toml"}

        ${notify} --stopping --status=""
      '';
    };

    rustic-nobbz-clean = {
      path = [pkgs.rustic pkgs.openssh];
      inherit environment;
      serviceConfig = {
        NotifyAccess = "all";
        Type = "notify";
      };
      script = ''
        ${notify} --ready
        ${notify} --status=forget
        rustic forget -P ${profile_name "nobbz.toml"} \
          --filter-tags home \
          --keep-last 4 \
          --keep-within-hourly 1d \
          --keep-within-daily 5d \
          --keep-within-weekly 35d \
          --keep-within-monthly 100d \
          --keep-within-yearly 2y

        ${notify} --status=prune
        rustic prune -P ${profile_name "nobbz.toml"} \
          --max-unused=0B \
          --keep-delete=12h \
          --max-repack=50GiB

        ${notify} --status=copy
        rustic copy -P ${profile_name "nobbz.toml"}

        ${notify} --stopping --status=""
      '';
    };

    rustic-nobbz-hetzner-clean = {
      path = [pkgs.rustic pkgs.openssh];
      inherit environment;
      serviceConfig = {
        NotifyAccess = "all";
        Type = "notify";
      };
      script = ''
        ${notify} --ready
        ${notify} --status=forget
        rustic forget -P ${profile_name "nobbz_hetzner.toml"} \
          --keep-last 1 \
          --keep-within-hourly 2h \
          --keep-within-daily 10d \
          --keep-within-weekly 65d \
          --keep-within-monthly 190d \
          --keep-within-yearly 5y

        ${notify} --status=prune
        rustic prune -P ${profile_name "nobbz_hetzner.toml"} \
          --max-unused 0B \
          --max-repack 20GiB \
          --keep-delete 11h

        ${notify} --stopping --status=""
      '';
    };

    rustic-mimas-hetzner-clean = {
      path = [pkgs.rustic pkgs.openssh];
      inherit environment;
      serviceConfig = {
        NotifyAccess = "all";
        Type = "notify";
      };
      script = ''
        ${notify} --ready
        ${notify} --status=forget
        rustic forget -P ${profile_name "mimas_hetzner.toml"} \
          --keep-last 1 \
          --keep-within-hourly 2h \
          --keep-within-daily 10d \
          --keep-within-weekly 65d \
          --keep-within-monthly 190d \
          --keep-within-yearly 5y

        ${notify} --status=prune
        rustic prune -P ${profile_name "mimas_hetzner.toml"} \
          --max-unused 0B \
          --max-repack 20GiB \
          --keep-delete 11h

        ${notify} --stopping --status=""
      '';
    };
  };
}
