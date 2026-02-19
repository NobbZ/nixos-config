# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{self, ...} @ inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  steamPackages = ["steam" "steam-run" "steam-original" "steam-runtime" "steam-unwrapped"];
in {
  imports = [
    ./mimas/services/gitea.nix
    ./mimas/services/glance.nix
    ./mimas/services/immich.nix
    ./mimas/services/paperless.nix
    (import ./mimas/services/restic.nix inputs)
    ./mimas/services/rustic-timers.nix
    ./mimas/services/searx.nix
    ./mimas/services/vaultwarden.nix
  ];

  services.tailscale.enable = true;
  programs.mosh.enable = true;

  security.pam.services.i3lock.enable = true;
  security.pam.services.i3lock-color.enable = true;

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.defaultSopsFile = "${self}/secrets/mimas/default.yaml";

  sops.secrets.restic = {};
  sops.secrets.traefik = {};

  nix.allowedUnfree = ["zerotierone"] ++ steamPackages;
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

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.openFirewall = true;

  services.ratbagd.enable = true;

  programs.partition-manager.enable = true;

  programs.kdeconnect.enable = true;

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

  # Enable pulse compat.
  services.pipewire.pulse.enable = true;

  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "de";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.windowManager.awesome.enable = true;
  xdg.portal.enable = true;

  services.dbus.packages = [pkgs.dconf];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666"
  '';

  # services.transmission.enable = true;
  systemd.services.transmission.after = ["var-lib-transmission.mount"];

  programs = {
    steam.enable = true;

    zsh.enable = true;
    zsh.enableCompletion = false;
  };

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [pkgs.intel-vaapi-driver];

  virtualisation = {
    docker = {
      enable = true;
      # storageDriver = "zfs";
      # extraOptions = "--storage-opt zfs.fsname=rpool/local/docker";
      package = pkgs.docker;
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

  hardware.keyboard.zsa.enable = true;
  hardware.sane.enable = true;

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

    certificatesResolvers.dashboardNobbzDev.acme = {
      email = "acme@nobbz.dev";
      storage = "/var/lib/traefik/dashboard.json";
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
    };
  };

  nix.buildMachines = let
    communityBuilder = name: system: {
      hostName = "${name}.nix-community.org";
      inherit system;
      sshKey = "/root/.ssh/id_ed25519";
      sshUser = "NobbZ";
      maxJobs = 8;
      protocol = "ssh";
      speedFactor = 4;
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
    };
  in [
    (communityBuilder "build-box" "x86_64-linux")
    (communityBuilder "aarch64-build.box" "aarch64-linux")
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
