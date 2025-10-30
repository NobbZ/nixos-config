_: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.rustic;

  bin = lib.getExe cfg.package;

  globs = let lines = map (g: "${g}\n") cfg.globs; in lib.concatStrings lines;
  globsFile = pkgs.writeText "globs" globs;
  globFlags = lib.optionals (cfg.globs != []) ["--glob-file" globsFile];

  oneFsFlags = lib.optional cfg.oneFileSystem "-x";

  flagList = ["--tag" "home"] ++ globFlags ++ oneFsFlags;
  flags = lib.concatStringsSep " " flagList;

  command = "${bin} backup ${flags} %h";

  profileModule = {
    name,
    config,
    ...
  }: {
    enable = lib.mkEnableOption name // {default = true;};

    repo = lib.mkOption {
      type = lib.types.str;
      description = "Location of the repository";
    };

    globs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Patterns to apply to backup. Use a hardcoded prefix for the home directory";
    };

    oneFileSystem = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If true, exclude other file systems, don't cross filesystem boundaries and subvolumes";
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/rustic/password";
      description = "Location of the password file";
    };

    source = lib.mkOption {
      type = lib.types.path;
      description = "Location of the base directory for the backup.Of ";
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.any;
      description = "A nix representation of the profile settings which gets converted to a TOML file";
    };
  };
in {
  options.services.rustic = {
    enable = lib.mkEnableOption "rustic";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.rustic;
      description = "Rustic derivation to use";
    };

    globs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Patterns to apply to backup. Use `%h` instead of `~`";
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

    passwordFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/rustic/password";
      description = "Location of the password file";
    };

    profile = lib.mkOption {
      type = lib.types.attrsOf profileModule;
      description = "Specifies the backup profile to use and its settings";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services.rustic-backup = {
      Unit = {
        Description = "Rustic Backup Tool";
        StartLimitIntervalSec = "25m";
        StartLimitBurst = "4";
      };

      Service = {
        LoadCredential = [
          "pass:${cfg.passwordFile}"
        ];
        Environment = [
          "RUSTIC_PASSWORD_FILE=%d/pass"
          "RUSTIC_REPOSITORY=${cfg.repo}"
        ];
        Type = "oneshot";
        ExecStart = command;
        Restart = "on-failure";
        RestartSec = "2m";
      };
    };

    systemd.user.timers.rustic-backup = {
      Unit.Description = "Rustic periodic backup";
      Install.WantedBy = ["timers.target"];
      Timer = {
        Unit = "rustic-backup.service";
        OnCalendar = "hourly"; # TODO: Make configurable!
      };
    };
  };
}
