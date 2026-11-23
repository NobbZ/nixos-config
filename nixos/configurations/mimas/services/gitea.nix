{
  pkgs,
  lib,
  config,
  ...
}: let
  gitea-gc-script = pkgs.writeShellApplication {
    name = "gitea-gc";
    runtimeInputs = [pkgs.findutils pkgs.git pkgs.systemd];
    text = ''
      repositories_base_folder=$1

      # <N> is the syslog priority prefix: journald parses it from our
      # stdout stream (SyslogLevelPrefix=, enabled by default), strips it
      # from the message and stores it as the entry's PRIORITY. The level
      # name stays in the message so it is visible in plain journalctl.
      log() {
        local level=$1
        shift

        local priority
        case $level in
          debug) priority=7 ;;
          info) priority=6 ;;
          warn) priority=4 ;;
          error) priority=3 ;;
          *) priority=6 ;;
        esac

        printf '<%s>[%s] %s\n' "$priority" "$level" "$*"
      }

      trap 'log error "garbage collection aborted (exit $?)"' ERR

      log info "Performing garbage collection for all repos in $repositories_base_folder"

      systemd-notify --ready

      mapfile -d "" -t repos < <(find "$repositories_base_folder" -maxdepth 2 -name '*.git' -print0)
      repo_count=''${#repos[@]}
      idx=0

      for repo in "''${repos[@]}"; do
        idx=$((idx + 1))
        short_name=''${repo#"$repositories_base_folder"/}

        log info "Starting garbage collection for $short_name"
        systemd-notify --status="$idx/$repo_count: $short_name"
        git -C "$repo" gc --aggressive --no-quiet
        log info "Finished garbage collection for $short_name"
      done

      systemd-notify --stopping

      log info "Overall garbage collection succeeded"
    '';
  };
in {
  services.gitea = {
    enable = true;
    settings.server.HTTP_ADDR = "127.0.0.1";
    settings.server.HTTP_PORT = config.lib.nobbz.mimas.ports.gitea;
    settings.server.ROOT_URL = lib.mkForce "https://gitea.mimas.internal.nobbz.dev/";
    settings."git.timeout".DEFAULT = 3600; # 1 hour
    settings."git.timeout".MIGRATE = 3600; # 1 hour
    settings."git.timeout".MIRROR = 3600; # 1 hour
    settings."git.timeout".CLONE = 3600; # 1 hour
    settings."git.timeout".PULL = 3600; # 1 hour
    settings."git.timeout".GC = 3600; # 1 hour
  };
  systemd.services.gitea = {
    after = ["var-lib-gitea.mount"];
    wants = ["var-lib-gitea.mount"];
    unitConfig.RequiresMountsFor = ["/var/lib/gitea"];
  };

  systemd = {
    services.gitea-gc = {
      description = "Garbage Collect gitea repositories";
      restartIfChanged = false;
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

  services.monit.config = ''
    check process gitea with pidfile /run/gitea/gitea.pid
      start program = "${lib.getExe' pkgs.systemd "systemctl"} start gitea"
      stop program = "${lib.getExe' pkgs.systemd "systemctl"} stop gitea"

      if failed host gitea.mimas.internal.nobbz.dev port 443 protocol https for 4 cycles then restart
      if failed host localhost port ${toString config.services.gitea.settings.server.HTTP_PORT} protocol http for 4 cycles then restart
  '';
}
