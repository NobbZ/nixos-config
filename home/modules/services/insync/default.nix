{
  self,
  nixpkgs-insync-v3,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.insync;
in {
  options.services.insync = {
    enable = lib.mkEnableOption "Insync cloud sync tool";

    package = lib.mkOption {
      type = lib.types.package;
      default = let ipkgs = import nixpkgs-insync-v3 {
          inherit (pkgs) system;
          inherit (config.nixpkgs) config;
        }; in ipkgs.insync-v3;
      description = ''
        The insync package to use.

        It will get automatically added to 'allowedUnfree'.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.allowedUnfree = ["insync"];

    home.packages = [cfg.package];

    systemd.user.services.insync = {
      Unit = {
        Description = "Insync - Google Drive, OneDrive, and Dropbox Syncing on Linux, Windows & Mac";
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };

      Install = {WantedBy = ["graphical-session.target"];};

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/insync start --no-daemon";
        ExecStop = "${cfg.package}/bin/insync stop";
        Restart = "always";
        RestartSec = "5";
      };
    };
  };
}
