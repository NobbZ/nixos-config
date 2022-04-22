{
  self,
  nixpkgs-2105,
  ...
}: {
  self,
  config,
  pkgs,
  modulesPath,
  ...
}: {
  # TODO: 👇 move import of `virtualbox-demo.nix` into extra module 👇
  imports = [(modulesPath + "/installer/virtualbox-demo.nix")];

  services.pdns-recursor.enable = true;

  nix.allowedUnfree = ["zerotierone"];

  boot.kernelPackages = pkgs.linuxPackages_5_16;

  networking.hostId = "deadbeef";

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "tty";
    };
  };

  users.users.demo = {
    isNormalUser = true;
    description = "Demo user account";
    extraGroups = ["wheel" "docker"];
    uid = 1000;
    shell = pkgs.zsh;
  };

  boot.kernel.sysctl = {
    "vm.max_map_count" = 262144;
  };

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = false;

  virtualisation = {
    docker.enable = true;
    docker.extraOptions = "--insecure-registry registry.cap01.cloudseeds.de";
    docker.liveRestore = false;
    podman.enable = true;
  };

  console.font = "Lat2-Terminus16";
  console.keyMap = "de";

  environment.systemPackages = [pkgs.unison];

  services.xserver.layout = pkgs.lib.mkForce "de";

  services.xserver.videoDrivers = ["vmware" "virtualbox" "modesetting"];
  systemd.services.virtualbox-resize = {
    description = "VirtualBox Guest Screen Resizing";

    wantedBy = ["multi-user.target"];
    requires = ["dev-vboxguest.device"];
    after = ["dev-vboxguest.device"];

    unitConfig.ConditionVirtualization = "oracle";

    serviceConfig.ExecStart = "@${config.boot.kernelPackages.virtualboxGuestAdditions}/bin/VBoxClient -fv --vmsvga";
  };

  # services.zerotierone.package = nixpkgs-2105.legacyPackages.${pkgs.system}.zerotierone;

  # services.ipfs.enable = true;

  services.openssh.enable = true;

  swapDevices = [
    {
      device = "/var/swap-2";
      size = 2048 * 4;
    }
  ];

  networking.hosts."127.0.0.1" = ["ax69_mysql"];
  networking.firewall.allowedTCPPorts = [
    # ports often used for development, that I want to expose for easier access from the host
    3000
    3306
    8080
    8081
    9002
  ];

  nix.distributedBuilds = false;
  nix.buildMachines = [
    {
      hostName = "builder-zerotier";
      system = "x86_64-linux";
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      mandatoryFeatures = [];
    }
  ];

  security.sudo.extraRules = [
    {
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
      ];
      groups = ["wheel"];
    }
  ];

  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        port = 9002;
      };
    };
  };

  system.stateVersion = "19.09";
}
