{ self, config, pkgs, nixpkgs-2105, modulesPath, ... }:

{
  # TODO: 👇 move import of `virtualbox-demo.nix` into extra module 👇
  imports = [ (modulesPath + "/installer/virtualbox-demo.nix") ];

  nixpkgs.config.allowUnfree = true;

  #   environment.extraSetup = ''
  #   ln -s ${pkgs.pinentry-gtk2}/bin/pinentry $out/bin/pinentry-gtk-2
  #   ln -s ${pkgs.pinentry-curses}/bin/pinentry $out/bin/pinentry-curses
  #   ln -s ${pkgs.pinentry}/bin/pinentry $out/bin/pinentry-tty
  #   ln -s $out/bin/pinentry-tty $out/bin/pinentry
  # '';

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "tty";
    };
  };

  # security.pam.services.login.gnupg.enable = true;

  users.users.demo =
    {
      isNormalUser = true;
      description = "Demo user account";
      extraGroups = [ "wheel" "docker" ];
      uid = 1000;
      shell = pkgs.zsh;
    };

  boot.kernel.sysctl = {
    "vm.max_map_count" = 262144;
  };

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = false;

  nix.useSandbox = true;
  nix.autoOptimiseStore = true;

  virtualisation = {
    docker.enable = true;
    docker.extraOptions = "--insecure-registry registry.cap01.cloudseeds.de";
    podman.enable = true;
  };

  console.font = "Lat2-Terminus16";
  console.keyMap = "de";

  services.xserver.layout = pkgs.lib.mkForce "de";

  services.xserver.videoDrivers = [ "vmware" "virtualbox" "modesetting" ];
  systemd.services.virtualbox-resize = {
    description = "VirtualBox Guest Screen Resizing";

    wantedBy = [ "multi-user.target" ];
    requires = [ "dev-vboxguest.device" ];
    after = [ "dev-vboxguest.device" ];

    unitConfig.ConditionVirtualization = "oracle";

    serviceConfig.ExecStart = "@${config.boot.kernelPackages.virtualboxGuestAdditions}/bin/VBoxClient -fv --vmsvga";
  };

  # environment.systemPackages = [ pkgs.pinentry.gnome3 ];

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "8286ac0e4768c8ae" ];
  services.zerotierone.package = (import nixpkgs-2105 { config.allowUnfree = true; system = pkgs.system; }).zerotierone;

  services.ipfs.enable = true;

  # Mount a VirtualBox shared folder.
  # This is configurable in the VirtualBox menu at
  # Machine / Settings / Shared Folders.
  # fileSystems."/mnt" = {
  #   fsType = "vboxsf";
  #   device = "nameofdevicetomount";
  #   options = [ "rw" ];
  # };

  services.openssh.enable = true;

  swapDevices = [{
    device = "/var/swap-2";
    size = 2048 * 4;
  }];

  networking.firewall.allowedTCPPorts = [
    # ports often used for development, that I want to expose for easier access from the host
    3000
    8080
    8081
  ];

  nix.distributedBuilds = false;
  nix.buildMachines = [
    {
      hostName = "builder-zerotier";
      system = "x86_64-linux";
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
}
