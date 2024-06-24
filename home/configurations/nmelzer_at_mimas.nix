{
  unstable,
  self,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}: {
  _file = ./nmelzer_at_mimas.nix;

  config = {
    nixpkgs.allowedUnfree = ["google-chrome" "vscode" "discord" "obsidian"];

    activeProfiles = ["browsing" "development"];

    sops.age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
    sops.defaultSopsFile = "${self}/secrets/mimas/nmelzer/default.yaml";

    sops.secrets.rustic.path = "${config.xdg.configHome}/rustic/password";

    dconf.enable = true;

    enabledLanguages = ["nix"];

    programs.emacs.splashScreen = false;

    home.packages = builtins.attrValues {
      inherit (pkgs) keybase-gui freerdp keepassxc nix-output-monitor discord;
      inherit (pkgs) obsidian;
      inherit (pkgs.gnome) gnome-tweaks;
      inherit (pkgs) vscode;
    };

    programs.obs-studio.enable = true;
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

    xsession.windowManager.awesome.autostart = [
      "${pkgs.blueman}/bin/blueman-applet"
      "${pkgs.networkmanagerapplet}/bin/nm-applet"
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
  };
  # environment.pathsToLink = [ "/share/zsh" ];
}
# /nix/store/7skqa8vxfydq7w3cix55ffvkmjb3b5da-python-2.7.18

