{ config, lib, pkgs, self, ... }:

let
  cfg = config.services.restic;

  bin = "${cfg.package}/bin/restic";
  excludes = __concatStringsSep " " (builtins.map (e: "--exclude=${e}") cfg.exclude);
  xFlags = lib.optionalString cfg.oneFileSystem "-x";
  flags = "${xFlags} ${excludes}";

  command = "${bin} -vv backup ${flags} %h";
in
{
  options.services.restic = {
    enable = lib.mkEnableOption "Restic Backup Tool";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.restic;
      description = "Restic derivation to use";
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Corresponds to `--exclude`. Use `%h` instead of `~`";
    };

    oneFileSystem = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If true, exclude other file systems, don't cross filesystem boundaries and subvolumes";
    };

    # TODO: Add options for inlcude, password file, etc
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.restic-backup = {
      Unit.Description = "Restic Backup Tool";

      Service = {
        Environment = [
          "RESTIC_PASSWORD_FILE=%h/.config/restic/password"
          "RESTIC_REPOSITORY=/run/media/nmelzer/data/restic/repo"
        ];
        ExecStart = command;
      };
    };

    systemd.user.timers.restic-backup = {
      Unit.Description = "Restic periodic backup";
      Timer = {
        Unit = "restic-backup.service";
        OnCalendar = "*:0/15";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
