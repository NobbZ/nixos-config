{
  pkgs,
  lib,
  config,
  ...
}: let
  writeNuBin = pkgs.writers.writeNuBin.override {makeBinaryWrapper = pkgs.makeShellWrapper;};
  
  find = lib.getExe pkgs.findutils;
  git = lib.getExe pkgs.git;
  systemd-notify = lib.getExe' pkgs.systemd "systemd-notify";
  
  gitea-gc-script =
    writeNuBin "gitea-gc"
    # nu
    ''
      use std log

      def main [
        repositories_base_folder: string,
      ] {
        log info $"Performing garbage collection for all repos in ($repositories_base_folder)"

        let repo_paths = run-external ${find} $repositories_base_folder "-maxdepth" 2 "-name" '*.git' | lines
        let repo_count = $repo_paths | length

        run-external ${systemd-notify} "--ready"

        $repo_paths | enumerate | each {|itm|
          let repo = $itm.item
          let idx = $itm.index

          let short_name = $repo | str substring --grapheme-clusters ($repositories_base_folder + "/" | str length)..-1

          log info $"Starting garbage collection for ($short_name)"
          run-external ${systemd-notify} $"--status=($idx + 1)/($repo_count): ($short_name)"
          run-external ${git} "-C" $repo gc "--aggressive" "--no-quiet"
          log info $"Finished garbage collection for ($short_name)"
        }

        run-external ${systemd-notify} "--stopping"

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
        AmbientCapabilities = "CAP_SYS_ADMIN";
        CPUAccounting = true;
        CPUQuota = "200%";
        CPUWeight = "idle";
        ExecStart = "${lib.getExe gitea-gc-script} /var/lib/gitea/repositories";
        RemainAfterExit = true;
        Type = "notify";
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
