{self, ...}: {
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.allowedUnfree = ["google-chrome" "vscode" "discord" "obsidian"];

  activeProfiles = ["browsing" "development"];

  sops.age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
  sops.defaultSopsFile = "${self}/secrets/mimas/nmelzer/default.yaml";

  sops.secrets.rustic.path = "${config.xdg.configHome}/rustic/password";

  dconf.enable = true;

  gtk.gtk2.force = true;

  home.packages = builtins.attrValues {
    inherit (pkgs) keybase-gui freerdp keepassxc nix-output-monitor discord;
    inherit (pkgs) obsidian;
    inherit (pkgs) gnome-tweaks;
    inherit (pkgs) vscode wezterm;
  };

  programs.htop = {
    settings = {
      detailed_cpu_time = true;
    };
    # meters.right = [
    #   { kind = "Battery"; mode = 1; }
    #   "Tasks"
    #   "LoadAverage"
    #   "Uptime"
    # ];
  };

  programs.yazi.enable = true;
  programs.yazi.shellWrapperName = "y";

  xsession.windowManager.awesome.autostart = [
    "${pkgs.blueman}/bin/blueman-applet"
    "${pkgs.networkmanagerapplet}/bin/nm-applet"
  ];

  systemd.user.tmpfiles.rules = [
    "d ${config.home.homeDirectory}/tmp 700 ${config.home.username} users 14d"
  ];

  services = {
    keybase.enable = true;
    kbfs.enable = true;
    insync.enable = true;
    playerctld.enable = true;
    flameshot.enable = true;

    rustic = {
      enable = true;
      passwordFile = config.sops.secrets.rustic.path;
      globs = let
        mkHome = e: "${config.home.homeDirectory}/${e}";
        mkIgnore = e: "!${e}";

        home = map mkHome ["Downloads" ".cache" ".cabal" ".cargo" ".emacs.d/eln-cache" ".emacs.d/.cache" ".gem" ".gradle" ".hex" ".kube" ".local" ".m2" ".minikube" ".minishift" ".mix" ".mozilla" "npm" ".opam" ".rancher" ".vscode-oss" "go/pkg" "timmelzer@gmail.com/restic_repos" ".local/share/libvirt" ".bitmonero"];
        patterns = ["_build" "Cache" "deps" "result" "target" ".elixir_ls" "ccls-cache" ".direnv" "direnv" "node_modules"];
      in
        map mkIgnore (home ++ patterns);
      oneFileSystem = true;
      repo = "rest:https://restic.mimas.internal.nobbz.dev/nobbz";
    };
  };

  systemd.user.services = {
    rustic.Unit.After = ["sops-nix.service"];
    keybase-gui = {
      Unit = {
        Description = "Keybase GUI";
        Requires = ["keybase.service" "kbfs.service"];
        After = ["keybase.service" "kbfs.service"];
      };
      Service = {
        ExecStart = "${pkgs.keybase-gui}/share/keybase/Keybase";
        PrivateTmp = true;
        # Slice      = "keybase.slice";
      };
    };
  };

  xdg.configFile = {
    "rustic/mimas-hetzner.toml".text =
      # toml
      ''
        [repository]
        repository = "rclone:hetzner-restic:mimas"
        password-file = "${config.sops.secrets.rustic.path}"
      '';
    "rustic/mimas.toml".text =
      # toml
      ''
        [repository]
        repository = "rest:https://restic.mimas.internal.nobbz.dev/mimas"
        password-file = "${config.sops.secrets.rustic.path}"

        [copy]
        targets = ["mimas-hetzner"]
      '';

    "rustic/nobbz-hetzner.toml".text =
      # toml
      ''
        [repository]
        repository = "rclone:hetzner-restic:nobbz"
        password-file = "${config.sops.secrets.rustic.path}"
      '';
    "rustic/nobbz.toml".text =
      # toml
      ''
        [repository]
        repository = "rest:https://restic.mimas.internal.nobbz.dev/nobbz"
        password-file = "${config.sops.secrets.rustic.path}"

        [copy]
        targets = ["nobbz-hetzner"]
      '';
  };

  home.stateVersion = "20.09";
}
