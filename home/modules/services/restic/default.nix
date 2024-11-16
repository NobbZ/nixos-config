{self, ...}: {
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.services.restic;

  bin = "${cfg.package}/bin/restic";
  excludes = builtins.concatStringsSep " " (builtins.map (e: "--exclude=${e}") cfg.exclude);
  xFlags = lib.optionalString cfg.oneFileSystem "-x";
  compressFlag = "--compression ${cfg.compression}";
  flags = "${xFlags} ${compressFlag} ${excludes}";

  command = "${bin} --tag home -vv backup ${flags} %h";
in {
  options.services.restic = {
    enable = lib.mkEnableOption "Restic Backup Tool";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.restic;
      description = "Restic derivation to use";
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Corresponds to `--exclude`. Use `%h` instead of `~`";
    };

    oneFileSystem = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If true, exclude other file systems, don't cross filesystem boundaries and subvolumes";
    };

    repo = lib.mkOption {
      type = lib.types.str;
      description = "Location of the repository";
    };

    compression = lib.mkOption {
      type = lib.types.enum ["off" "auto" "max"];
      description = "The compression mode to use";
      default = "auto";
    };

    # TODO: Add options for inlcude, password file, etc
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services.restic-backup = {
      Unit = {
        Description = "Restic Backup Tool";
        StartLimitIntervalSec = "25m";
        StartLimitBurst = "4";
      };

      Service = {
        Environment = [
          "PATH=${lib.makeBinPath [pkgs.openssh]}"
          "RESTIC_PASSWORD_FILE=%h/.config/restic/password"
          "RESTIC_REPOSITORY=${cfg.repo}"
        ];
        Type = "oneshot";
        ExecStart = command;
        Restart = "on-failure";
        RestartSec = "2m";
      };
    };

    systemd.user.timers.restic-backup = {
      Unit.Description = "Restic periodic backup";
      Timer = {
        Unit = "restic-backup.service";
        OnCalendar = "hourly";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
