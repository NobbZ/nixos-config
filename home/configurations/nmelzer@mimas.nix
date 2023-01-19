{
  unstable,
  self,
  ...
}: {
  config,
  pkgs,
  ...
}: {
  config = {
    nixpkgs.allowedUnfree = ["google-chrome" "vscode" "discord"];
    nixpkgs.config.allowBroken = true;

    activeProfiles = ["browsing" "development"];

    dconf.enable = true;

    enabledLanguages = [
      # "agda"  # Seems as if AGDA2-mode isn't on melpa anymore
      "clojure"
      "cpp"
      "elixir"
      "erlang"
      "go"
      "nim"
      "nix"
      # "ocaml"
      "rust"
      "tex"
    ];

    programs.emacs.splashScreen = false;

    home.packages = builtins.attrValues {
      inherit (pkgs) keybase-gui freerdp vscode keepassxc nix-output-monitor discord;
      inherit (pkgs.gnome) gnome-tweaks;
      inherit (self.packages.x86_64-linux) gnucash-de;
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

      rustic = {
        enable = true;
        globs = let
          mkHome = e: "${config.home.homeDirectory}/${e}";
          mkIgnore = e: "!${e}";

          home = map mkHome [".cache" ".cabal" ".cargo" ".emacs.d/eln-cache" ".emacs.d/.cache" ".gem" ".gradle" ".hex" ".kube" ".local" ".m2" ".minikube" ".minishift" ".mix" ".mozilla" "npm" ".opam" ".rancher" ".vscode-oss" "go/pkg" "timmelzer@gmail.com/restic_repos"];
          patterns = ["_build" "Cache" "deps" "result" "target" ".elixir_ls" "ccls-cache" ".direnv" "direnv" "node_modules"];
        in
          map mkIgnore (home ++ patterns);
        oneFileSystem = true;
        repo = "rest:https://restic.mimas.internal.nobbz.dev/nobbz";
      };
    };

    systemd.user.services = {
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

