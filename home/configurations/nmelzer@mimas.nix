{
  unstable,
  self,
  ...
}: {pkgs, ...}: let
  keepassWithPlugins =
    pkgs.keepass.override {plugins = [pkgs.keepass-keepasshttp];};
in {
  config = {
    nixpkgs.allowedUnfree = ["teamspeak-client" "google-chrome" "vscode" "teams"];

    activeProfiles = ["browsing" "development" "home-office"];

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
      "python"
      "rust"
      "tex"
    ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages = let
      p = pkgs;
      s = self.packages.x86_64-linux;
    in [
      p.handbrake
      p.keybase-gui
      p.minikube
      p.gnome3.gnome-tweaks
      p.freerdp
      p.vscode
      p.teams

      s.gnucash-de

      keepassWithPlugins
    ];

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
      keyleds.enable = true;
      keybase.enable = true;
      kbfs.enable = true;
      insync.enable = true;

      restic = {
        enable = true;
        exclude = (map (e: "%h/${e}") [".cache" ".cabal" ".cargo" ".emacs.d/eln-cache" ".emacs.d/.cache" ".gem" ".gradle" ".hex" ".kube" ".local" ".m2" ".minikube" ".minishift" ".mix" ".mozilla" "npm" ".opam" ".rancher" ".vscode-oss" "go/pkg"]) ++ ["_build" "deps" "result" "target" ".elixir_ls" "ccls-cache" ".direnv"];
        oneFileSystem = true;
        repo = "rest:http://172.24.152.168:9999/nobbz";
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

