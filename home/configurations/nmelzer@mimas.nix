{ pkgs, unstable, self, ... }:
let
  keepassWithPlugins =
    pkgs.keepass.override { plugins = [ pkgs.keepass-keepasshttp ]; };
in
{
  config = {
    nixpkgs.allowedUnfree = [ "teamspeak-client" "google-chrome" "insync" ];

    activeProfiles = [ "browsing" "development" "home-office" ];

    dconf.enable = true;

    enabledLanguages = [
      "agda"
      "clojure"
      "cpp"
      "elixir"
      "erlang"
      "go"
      "nix"
      # "ocaml"
      "python"
      "rust"
      "tex"
    ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages =
      let
        p = pkgs;
        s = self.packages.x86_64-linux;
      in
      [
        p.insync
        p.handbrake
        p.keybase-gui
        p.minikube
        p.gnome3.gnome-tweaks

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
    };

    systemd.user.services = {
      keybase-gui = {
        Unit = {
          Description = "Keybase GUI";
          Requires = [ "keybase.service" "kbfs.service" ];
          After = [ "keybase.service" "kbfs.service" ];
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
