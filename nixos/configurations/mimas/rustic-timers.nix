_: {
  config,
  pkgs,
  lib,
  ...
}: let
  mimas_template =
    # toml
    ''
      [repository]
      repository = "rest:https://restic.mimas.internal.nobbz.dev/mimas"
      password-file = "${config.sops.secrets.rustic.path}"

      [copy]
      targets = ["${lib.removeSuffix ".toml" config.sops.templates."mimas_hetzner.toml".path}"]
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
      targets = ["${lib.removeSuffix ".toml" config.sops.templates."nobbz_hetzner.toml".path}"]
    '';

  nobbz_hetzner_template =
    # toml
    ''
      [repository]
      repository = "opendal:sftp"
      password-file ="${config.sops.secrets.rustic.path}"

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
      timerConfig.onCalendar = calendar;
    };
  };
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
      serviceConfig.Type = "oneshot";
      script = ''
        rustic forget -P ${lib.removeSuffix ".toml" config.sops.templates."mimas.toml".path} \
          --keep-last 4 \
          --keep-within-hourly 1d \
          --keep-within-daily 5d \
          --keep-within-weekly 35d \
          --keep-within-monthly 100d \
          --keep-within-yearly 2y

        rustic prune -P ${lib.removeSuffix ".toml" config.sops.templates."mimas.toml".path} \
          --max-unused=0B \
          --keep-delete=12h \
          --max-repack=50GiB

        rustic copy -P ${lib.removeSuffix ".toml" config.sops.templates."mimas.toml".path}
      '';
    };

    rustic-nobbz-clean = {
      path = [pkgs.rustic pkgs.openssh];
      serviceConfig.Type = "oneshot";
      script = ''
        rustic forget -P ${lib.removeSuffix ".toml" config.sops.templates."nobbz.toml".path} \
          --filter-tags home \
          --keep-last 4 \
          --keep-within-hourly 1d \
          --keep-within-daily 5d \
          --keep-within-weekly 35d \
          --keep-within-monthly 100d \
          --keep-within-yearly 2y

        rustic prune -P ${lib.removeSuffix ".toml" config.sops.templates."nobbz.toml".path} \
          --max-unused=0B \
          --keep-delete=12h \
          --max-repack=50GiB

        rustic copy -P ${lib.removeSuffix ".toml" config.sops.templates."nobbz.toml".path}
      '';
    };

    rustic-nobbz-hetzner-clean = {
      path = [pkgs.rustic pkgs.openssh];
      serviceConfig.Type = "oneshot";
      script = ''
        rustic forget -P ${lib.removeSuffix ".toml" config.sops.templates."nobbz_hetzner.toml".path} \
          --keep-last 1 \
          --keep-within-hourly 2h \
          --keep-within-daily 10d \
          --keep-within-weekly 65d \
          --keep-within-monthly 190d \
          --keep-within-yearly 5y

        rustic prune -P ${lib.removeSuffix ".toml" config.sops.templates."nobbz_hetzner.toml".path} \
          --max-unused 0B \
          --max-repack 50GiB \
          --keep-delete 11h
      '';
    };

    rustic-mimas-hetzner-clean = {
      path = [pkgs.rustic pkgs.openssh];
      serviceConfig.Type = "oneshot";
      script = ''
        rustic forget -P ${lib.removeSuffix ".toml" config.sops.templates."mimas_hetzner.toml".path} \
          --keep-last 1 \
          --keep-within-hourly 2h \
          --keep-within-daily 10d \
          --keep-within-weekly 65d \
          --keep-within-monthly 190d \
          --keep-within-yearly 5y

        rustic prune -P ${lib.removeSuffix ".toml" config.sops.templates."mimas_hetzner.toml".path} \
          --max-unused 0B \
          --max-repack 50GiB \
          --keep-delete 11h
      '';
    };
  };
}
