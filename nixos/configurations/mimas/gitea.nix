{
  pkgs,
  lib,
  config,
  ...
}: let
  writeNuBin = pkgs.writers.writeNuBin.override {makeBinaryWrapper = pkgs.makeShellWrapper;};
  git = lib.getExe pkgs.git;
  gitea-gc-script =
    writeNuBin "gitea-gc"
    # nu
    ''
      use std log

      def main [
        repositories: string,
      ] {
        log info $"Performing garbage collection for all repos in ($repositories)"

        ${lib.getExe pkgs.findutils} $repositories "-maxdepth" 2 "-name" '*.git'
        | inspect
        | lines
        | inspect
        | each {|repo|
          log info $"Starting garbage collection for ($repo)"
          ${git} -C $repo gc --aggressive
          log info $"Finished garbage collection for ($repo)"
        }

        log info "Overall garbage collection suceeded"
      }
    '';
in {
  systemd = {
    services.gitea-gc = {
      description = "Garbage Collect gitea repositories";
      environment = {
        NU_LOG_LEVEL = "DEBUG";
      };
      serviceConfig = {
        CPUAccounting = true;
        CPUQuota = "200%";
        CPUWeight = "idle";
        ExecStart = "${lib.getExe gitea-gc-script} /var/lib/gitea/repositories";
        RemainAfterExit = true;
        Type = "oneshot";
        User = config.services.gitea.user;
      };
    };

    timers.gitea-gc = {
      description = "Garbage Collection for gitea repositories - timer";
      wantedBy = ["timers.target"];
      timerConfig.OnCalendar = "Mon 01:00:00";
    };
  };
}
