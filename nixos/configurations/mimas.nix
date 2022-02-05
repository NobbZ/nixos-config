# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, unstable, ... }:
let
  upkgs = import unstable { system = "x86_64-linux"; };
  steamPackages = [ "steam" "steam-original" "steam-runtime" ];
  printerPackages = [ "hplip" "samsung-UnifiedLinuxDriver" ];
in
{
  imports = [ ];

  nix.allowedUnfree = [ "zerotierone" ] ++ printerPackages ++ steamPackages;

  security.chromiumSuidSandbox.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "exfat" "avfs" ];
  boot.cleanTmpDir = true;
  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;

  services.lvm.boot.thin.enable = true;

  hardware.enableRedistributableFirmware = true;
  # networking.enableRalinkFirmware = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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
  networking.extraHosts = ''
    # 127.0.0.1 versions.teamspeak.com files.teamspeak-services.com
  '';
  # networking.firewall.extraCommands = ''
  #   iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -s 10.42.0.0/16 -d 127.0.0.1/32 -j ACCEPT
  #   iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 6445 -s 10.42.0.0/16 -d 127.0.0.1/32 -j ACCEPT
  # '';

  # services.k3s.enable = true;
  # services.k3s.extraFlags = "--write-kubeconfig-mode 0644 --node-external-ip 192.168.178.54 --node-external-ip 172.24.152.168";
  # systemd.services.k3s.after = [ "var-lib-rancher.mount" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  environment.systemPackages = with pkgs; [ virt-manager iptables ];

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

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "8286ac0e4768c8ae" ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 1111 8080 9002 9003 2342 9999 3000 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # services.fwupd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin pkgs.samsungUnifiedLinuxDriver ];

  services.ratbagd.enable = true;

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
  services.xserver.layout = "de";
  # services.xserver.xkbOptions = "eurosign:e";

  services.restic.server.enable = true;
  services.restic.server.prometheus = true;
  services.restic.server.extraFlags = [ "--no-auth" ];
  services.restic.server.listenAddress = "172.24.152.168:9999";
  systemd.services.restic-rest-server.after = [ "var-lib-restic.mount" ];

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.windowManager.awesome.enable = true;

  services.dbus.packages = with pkgs; [ pkgs.dconf ];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666"
  '';

  services.transmission.enable = true;
  systemd.services.transmission.after = [ "var-lib-transmission.mount" ];

  programs = {
    steam.enable = true;
    zsh.enable = true;
    zsh.enableCompletion = false;
  };

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = [ pkgs.vaapiIntel pkgs.beignet ];

  services.gitea.enable = true;

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
    virtualbox.host.enable = true;
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
      extraGroups = [ ];
    };
  };

  security.sudo.extraRules = [
    {
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }
  ];

  # services.wakeonlan.interfaces = [
  #   {
  #     interface = "enp5s0f2";
  #     method = "magicpacket";
  #   }
  # ];

  # grafana configuration
  services.grafana = {
    enable = true;
    domain = "grafana.nobbz.lan";
    port = 2342;
    addr = "0.0.0.0";
  };

  # nginx reverse proxy
  services.nginx.virtualHosts.${config.services.grafana.domain} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
      proxyWebsockets = true;
    };
  };

  services.traefik.enable = true;
  systemd.services.traefik.serviceConfig.EnvironmentFile = "/etc/traefik/env";
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
      dnsChallenge.resolvers = [ "1.1.1.1:53" "8.8.8.8:53" ];
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
        entrypoints = [ "traefik" ];
        rule = "PathPrefix(`/api/`)";
        service = "api@internal";
      };
      minio = {
        entryPoints = [ "http" ];
        rule = "Host(`fritz.mimas.internal.nobbz.dev`) && PathPrefix(`/`)";
        service = "fritz";
        tls.domains = [{ main = "*.mimas.internal.nobbz.dev"; }];
        tls.certResolver = "mimasWildcard";
      };
      minio-tls = {
        entryPoints = [ "https" "experimental" ];
        rule = "HostRegexp(`{subdomain:[a-z0-9]+}.mimas.internal.nobbz.dev`) && PathPrefix(`/`)";
        service = "minio";
        tls.domains = [{ main = "*.mimas.internal.nobbz.dev"; }];
        tls.certresolver = "mimasWildcard";
      };
    };
    http.services = {
      minio.loadBalancer.passHostHeader = true;
      minio.loadBalancer.servers = [{ url = "http://192.168.122.122/"; }];

      fritz.loadBalancer.passHostHeader = false;
      fritz.loadBalancer.servers = [{ url = "http://fritz.box"; }];
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
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };

    scrapeConfigs = [
      {
        job_name = "grafana";
        static_configs = [{ targets = [ "127.0.0.1:2342" ]; }];
      }
      {
        job_name = "prometheus";
        static_configs = [{ targets = [ "127.0.0.1:9001" ]; }];
      }
      {
        job_name = "node_import";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            "172.24.199.101:9002"
            "172.24.231.199:9002"
          ];
        }];
      }
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
