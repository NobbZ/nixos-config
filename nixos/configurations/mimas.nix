# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  self,
  unstable,
  nixpkgs-2211,
  ...
} @ inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  upkgs = unstable.legacyPackages.x86_64-linux;
  steamPackages = ["steam" "steam-run" "steam-original" "steam-runtime"];
  printerPackages = ["hplip" "samsung-UnifiedLinuxDriver"];
in {
  _file = ./mimas.nix;

  imports = [
    (import ./mimas/restic.nix inputs)
    (import ./mimas/paperless.nix inputs)
    (import ./mimas/vaultwarden.nix inputs)
  ];

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.defaultSopsFile = "${self}/secrets/mimas/default.yaml";

  sops.secrets.restic = {};
  sops.secrets.traefik = {};

  nix.allowedUnfree = ["zerotierone"] ++ printerPackages ++ steamPackages;
  nix.settings.experimental-features = ["ca-derivations" "impure-derivations"];
  nix.distributedBuilds = true;
  # nix.enabledMachines = ["enceladeus"];

  security.chromiumSuidSandbox.enable = true;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 25;

  services.lvm.boot.thin.enable = true;
  boot.enableContainers = false;

  boot.binfmt.emulatedSystems = ["i686-linux" "aarch64-linux"];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
  nix.settings.system-features = ["nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-core2" "gccarch-haswell"];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp5s0f2.useDHCP = false;
  networking.interfaces.wlp4s0.useDHCP = false;
  networking.hostId = "21025bb1";
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [
    # "mac:80:fa:5b:09:15:6e"
  ];

  # Select internationalisation properties.
  i18n = {
    # consoleFont = "Lat2-Terminus16";
    # consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  console.font = "Lat2-Terminus16";
  console.keyMap = "de";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    virt-manager
    iptables
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Add to XDG_DATA_DIRS:
  # * /var/lib/flatpak/exports/share
  # * $HOME/.local/share/flatpak/exports/share
  services.flatpak.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [80 443 1111 5555 8080 9002 9003 58080 4001];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # services.fwupd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.hplipWithPlugin pkgs.samsung-unified-linux-driver];

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.openFirewall = true;

  services.ratbagd.enable = true;

  programs.partition-manager.enable = true;
  # security.polkit.enable = true;

  # services.hydra = {
  #   enable = true;
  #   package = pkgs.hydra-unstable;

  #   hydraURL = "https://localhost:3000";
  #   notificationSender = "hydra@localhost";
  #   buildMachinesFiles = [ ];
  #   useSubstitutes = true;
  # };
  # networking.firewall.allowedTCPPorts = [ 3000 ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.windowManager.awesome.enable = true;

  services.dbus.packages = [pkgs.dconf];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666"
  '';

  services.transmission.enable = true;
  systemd.services.transmission.after = ["var-lib-transmission.mount"];

  programs = {
    steam.enable = true;

    zsh.enable = true;
    zsh.enableCompletion = false;
  };

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = [pkgs.vaapiIntel];

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

  virtualisation = {
    docker = {
      enable = true;
      # storageDriver = "zfs";
      # extraOptions = "--storage-opt zfs.fsname=rpool/local/docker";
      package = upkgs.docker;
      extraOptions = "--dns 1.1.1.1";
    };

    containers.enable = true;

    libvirtd.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  users.users = {
    nmelzer = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "audio"
        "networkmanager"
        "vboxusers"
        "libvirtd"
        "docker"
        "transmission"
        "scanner"
        "lp"
      ];
    };

    gamer = {
      isNormalUser = true;
      extraGroups = [
        "audio"
        "networkmanager"
      ];
    };

    aroemer = {
      isNormalUser = true;
      extraGroups = [];
    };
  };

  security.sudo.extraConfig = "Defaults passwd_timeout=0";

  # services.wakeonlan.interfaces = [
  #   {
  #     interface = "enp5s0f2";
  #     method = "magicpacket";
  #   }
  # ];

  # grafana configuration
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.mimas.internal.nobbz.lan";
      http_port = 2342;
      http_addr = "127.0.0.1";
    };
  };

  # nginx reverse proxy
  services.nginx.virtualHosts.${config.services.grafana.domain} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };

  hardware.keyboard.zsa.enable = true;
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [pkgs.hplipWithPlugin];

  services.traefik.enable = true;
  systemd.services.traefik.serviceConfig.EnvironmentFile = [config.sops.secrets.traefik.path];
  services.traefik.staticConfigOptions = {
    log.level = "DEBUG";

    api.dashboard = true;
    api.insecure = true;
    # experimental.http3 = true;

    certificatesResolvers.mimasWildcard.acme = {
      email = "acme@nobbz.dev";
      storage = "/var/lib/traefik/mimas.json";
      # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
      dnsChallenge.provider = "cloudflare";
      dnsChallenge.resolvers = ["1.1.1.1:53" "8.8.8.8:53"];
    };

    entryPoints = {
      http = {
        address = ":80";
        forwardedHeaders.insecure = true;
        http.redirections.entryPoint = {
          to = "https";
          scheme = "https";
        };
      };

      https = {
        address = ":443";
        # enableHTTP3 = true;
        forwardedHeaders.insecure = true;
      };

      experimental = {
        address = ":1111";
        forwardedHeaders.insecure = true;
      };
    };
  };
  services.traefik.dynamicConfigOptions = {
    http.routers = {
      api = {
        entrypoints = ["traefik"];
        rule = "PathPrefix(`/api/`)";
        service = "api@internal";
      };
      fritz = {
        entryPoints = ["https" "http"];
        rule = "Host(`fritz.mimas.internal.nobbz.dev`)";
        service = "fritz";
        tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
        tls.certResolver = "mimasWildcard";
      };
      gitea = {
        entryPoints = ["https" "http"];
        rule = "Host(`gitea.mimas.internal.nobbz.dev`)";
        service = "gitea";
        tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
        tls.certResolver = "mimasWildcard";
      };
      grafana = {
        entryPoints = ["https" "http"];
        rule = "Host(`grafana.mimas.internal.nobbz.dev`)";
        service = "grafana";
        tls.domains = [{main = "*.mimas.internal.nobbz.dev";}];
        tls.certResolver = "mimasWildcard";
      };
      # minio-tls = {
      #   entryPoints = [ "https" "experimental" ];
      #   rule = "HostRegexp(`{subdomain:[a-z0-9]+}.mimas.internal.nobbz.dev`) && PathPrefix(`/`)";
      #   service = "minio";
      #   tls.domains = [{ main = "*.mimas.internal.nobbz.dev"; }];
      #   tls.certresolver = "mimasWildcard";
      # };
    };
    http.services = {
      minio.loadBalancer.passHostHeader = true;
      minio.loadBalancer.servers = [{url = "http://192.168.122.122/";}];

      fritz.loadBalancer.passHostHeader = false;
      fritz.loadBalancer.servers = [{url = "http://fritz.box";}];

      gitea.loadBalancer.passHostHeader = true;
      gitea.loadBalancer.servers = [{url = "http://localhost:${toString config.services.gitea.settings.server.HTTP_PORT}";}];

      grafana.loadBalancer.passHostHeader = true;
      grafana.loadBalancer.servers = [{url = "http://localhost:${toString config.services.grafana.settings.server.http_port}";}];
    };
  };

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

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
