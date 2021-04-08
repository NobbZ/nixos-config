{ pkgs, ... }:
let
  nixos = import pkgs.inputs.nixpkgs-stable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };

  keepassWithPlugins =
    pkgs.keepass.override { plugins = [ pkgs.keepass-keepasshttp ]; };
in
{
  config = {
    activeProfiles = [ "browsing" "development" "home-office" ];

    dconf.enable = true;

    enabledLanguages = [
      "agda"
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
      [ nixos.insync pkgs.handbrake keepassWithPlugins pkgs.keybase-gui pkgs.minikube pkgs.lutris pkgs.steam ];

    programs.obs-studio.enable = true;
    programs.htop = {
      detailedCpuTime = true;
      meters.right = [
        { kind = "Battery"; mode = 1; }
        "Tasks" "LoadAverage" "Uptime"
      ];
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
