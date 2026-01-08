# Mimas Configuration Refactoring Implementation Plan

## Overview

This document contains the complete implementation details for refactoring the `mimas` NixOS configuration to unify service definitions and ensure each web service has its traefik routing configuration included.

## Current State Issues

- `mimas.nix` has 419 lines with mixed concerns (system + service configs)
- Gitea config is split: service in `mimas.nix`, GC timer in `mimas/gitea.nix`
- Grafana config split: service + nginx in `mimas.nix`, traefik route in `mimas.nix`
- Prometheus service config in `mimas.nix`, no traefik route
- Traefik routes scattered throughout `mimas.nix`

## Target Structure

```
nixos/configurations/mimas/
├── mimas.nix                          # Clean main config (~150 lines)
└── services/                          # NEW: All service definitions
    ├── gitea.nix                      # NEW: Complete gitea config
    ├── grafana.nix                    # NEW: Complete grafana config
    ├── prometheus.nix                 # NEW: Complete prometheus config
    ├── paperless.nix                  # MOVED from mimas/
    ├── vaultwarden.nix                # MOVED from mimas/
    ├── searx.nix                      # MOVED from mimas/
    ├── restic.nix                     # MOVED from mimas/
    └── rustic-timers.nix              # MOVED from mimas/
```

## Implementation Steps

### Step 1: Create Services Directory
```bash
mkdir -p nixos/configurations/mimas/services
```

### Step 2: Move Existing Service Files

Move these files with NO content changes:
- `mimas/paperless.nix` → `mimas/services/paperless.nix`
- `mimas/vaultwarden.nix` → `mimas/services/vaultwarden.nix`
- `mimas/searx.nix` → `mimas/services/searx.nix`
- `mimas/restic.nix` → `mimas/services/restic.nix`
- `mimas/rustic-timers.nix` → `mimas/services/rustic-timers.nix`

### Step 3: Create `services/gitea.nix`

**Content sources:**
- Service config: `mimas.nix:168-180`
- GC timer logic: `mimas/gitea.nix:47-71`
- Traefik route: `mimas.nix:315-321, 344-345`

**File content:**
```nix
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
```

### Step 4: Create `services/grafana.nix`

**Content sources:**
- Service config: `mimas.nix:242-249`
- Nginx proxy: `mimas.nix:252-257` (KEEP - module implementation detail)
- Traefik route: `mimas.nix:322-328, 347-348`

**File content:**
```nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.mimas.internal.nobbz.lan";
      http_port = 2342;
      http_addr = "127.0.0.1";
    };
  };

  # nginx reverse proxy - required by grafana module
  services.nginx.virtualHosts.${config.services.grafana.domain} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.grafana = {
    entryPoints = ["https" "http"];
    rule = "Host(`grafana.mimas.internal.nobbz.dev`)";
    service = "grafana";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.grafana.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://localhost:${toString config.services.grafana.settings.server.http_port}";}];
  };
}
```

### Step 5: Create `services/prometheus.nix`

**Content sources:**
- Service config: `mimas.nix:352-395`
- Traefik route: NEW (not currently present)
- Domain: `prometheus.mimas.internal.nobbz.dev`

**File content:**
```nix
{
  config,
  lib,
  ...
}: {
  services.prometheus = {
    enable = true;
    port = 9001;

    rules = [
      ''
        groups:
        - name: test
          rules:
          - record: nobbz:code_cpu_percent
            expr: avg without (cpu) (irate(node_cpu_seconds_total[5m]))
      ''
    ];

    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        port = 9002;
      };
    };

    scrapeConfigs = [
      {
        job_name = "grafana";
        static_configs = [{targets = ["127.0.0.1:2342"];}];
      }
      {
        job_name = "prometheus";
        static_configs = [{targets = ["127.0.0.1:9001"];}];
      }
      {
        job_name = "node_import";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              "${config.lib.nobbz.enceladeus.v4}:9002"
            ];
          }
        ];
      }
    ];
  };

  services.traefik.dynamicConfigOptions.http.routers.prometheus = {
    entryPoints = ["https" "http"];
    rule = "Host(`prometheus.mimas.internal.nobbz.dev`)";
    service = "prometheus";
    tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
    tls.certResolver = "mimasWildcard";
  };

  services.traefik.dynamicConfigOptions.http.services.prometheus.loadBalancer = {
    passHostHeader = true;
    servers = [{url = "http://127.0.0.1:${toString config.services.prometheus.port}";}];
  };
}
```

### Step 6: Update `mimas.nix`

**Remove from `mimas.nix`:**
- Lines 13-18: Current import statements
- Lines 168-180: Gitea service configuration
- Lines 242-257: Grafana service config + nginx proxy
- Lines 315-321: Gitea traefik router/service
- Lines 322-328: Grafana traefik router
- Lines 337-350: Traefik services (gitea, grafana, minio) - KEEP fritz, REMOVE minio
- Lines 352-395: Prometheus service config

**Add to `mimas.nix` (after line 12):**
```nix
  imports = [
    ./services/gitea.nix
    ./services/grafana.nix
    ./services/paperless.nix
    ./services/prometheus.nix
    ./services/restic.nix
    ./services/rustic-timers.nix
    ./services/searx.nix
    ./services/vaultwarden.nix
  ];
```

**Keep in `mimas.nix`:**
- Traefik base config: `services.traefik.enable` + `staticConfigOptions` (lines 262-300)
- Traefik base dynamic config: api router, fritz router/service (lines 302-307, 308-314, 341-342)
- All system settings: networking, locale, users, sudo, system packages
- All base services: openssh, flatpak, printing, avahi, ratbagd, partition-manager, kdeconnect
- All hardware: bluetooth, graphics, zsa keyboard, sane scanner
- All virtualization: docker, containers, libvirtd
- All other configs: sops, nix, zram, lvm, binfmt, etc.

### Step 7: Delete Old File
```bash
rm nixos/configurations/mimas/gitea.nix
```

## Summary of Changes

**Files Created:** 3
- `mimas/services/gitea.nix` (merged service + GC + traefik)
- `mimas/services/grafana.nix` (service + nginx + traefik)
- `mimas/services/prometheus.nix` (service + traefik)

**Files Moved:** 5
- `mimas/paperless.nix` → `mimas/services/paperless.nix`
- `mimas/vaultwarden.nix` → `mimas/services/vaultwarden.nix`
- `mimas/searx.nix` → `mimas/services/searx.nix`
- `mimas/restic.nix` → `mimas/services/restic.nix`
- `mimas/rustic-timers.nix` → `mimas/services/rustic-timers.nix`

**Files Modified:** 1
- `mimas/mimas.nix` (remove ~120 lines, add ~10 lines)

**Files Deleted:** 1
- `mimas/gitea.nix` (merged into `services/gitea.nix`)

**Expected Result:**
- `mimas.nix` reduced from 419 to ~150 lines
- All service definitions unified in single files
- Each web service has its traefik route included
- Traefik base config remains in main file
- Alphabetical import order for consistency

## Validation Steps

### Build Test
```bash
nix build .#nixosConfigurations.mimas.config.system.build.toplevel
```

### Format Check
```bash
nix fmt .
```

### Lint Check
```bash
statix check -i packages/nodePackages/node-env.nix
```

### Verify Service Routes
Check that all services have traefik routes defined in their files and no duplicate configs exist.

## Risk Assessment

**Low Risk:**
- Moving existing files with no content changes
- Following established patterns from already-well-structured services

**Medium Risk:**
- Merging gitea configs from two files
- Ensuring all traefik routes are correctly moved/created

**Mitigations:**
- Build test before committing
- Compare service configs carefully during extraction
- Verify all traefik routes present and correct

## Notes

- Keep both nginx (module implementation) and traefik (external access) for grafana
- Remove minio traefik route but keep fritz route
- Use domain `prometheus.mimas.internal.nobbz.dev` for prometheus
- Maintain alphabetical import order in mimas.nix
- All moved files should have no content changes