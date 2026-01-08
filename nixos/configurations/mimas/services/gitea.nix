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
  services.gitea = {
    enable = true;
    settings.server.DOMAIN = "gitea.mimas.internal.nobbz.dev";
    settings.server.HTTP_ADDR = "127.0.0.1";
    settings.server.ROOT_URL = lib.mkForce "https://gitea.mimas.internal.nobbz.dev/";
    settings."git.timeout".DEFAULT = 3600; # 1 hour
    settings."git.timeout".MIGRATE = 3600; # 1 hour
    settings."git.timeout".MIRROR = 3600; # 1 hour
    settings."git.timeout".CLONE = 3600; # 1 hour
    settings."git.timeout".PULL = 3600; # 1 hour
    settings."git.timeout".GC = 3600; # 1 hour
  };
  systemd.services.gitea.after = ["var-lib-gitea.mount"];

  systemd = {
    services.gitea-gc = {
      description = "Garbage Collect gitea repositories";
      restartIfChanged = false;
      environment = {
        NU_LOG_LEVEL = "DEBUG";
      };
      serviceConfig = {
        CPUAccounting = true;
        CPUQuota = "200%";
        CPUWeight = "idle";
        ExecStart = "${lib.getExe gitea-gc-script} /var/lib/gitea/repositories";
        NotifyAccess = "all";
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

  services.traefik.dynamicConfigOptions.http.routers.gitea = {
    entryPoints = ["https" "http"];
    rule = "Host(`gitea.mimas.internal.nobbz.dev`)";
    service = "gitea";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.gitea.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://localhost:${toString config.services.gitea.settings.server.HTTP_PORT}";}];
  };
}
