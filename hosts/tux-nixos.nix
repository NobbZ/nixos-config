{ pkgs, config, ... }:
let
  nixos = import <nixos> { config.allowUnfree = true; };

  keepassWithPlugins =
    pkgs.keepass.override { plugins = [ pkgs.keepass-keepasshttp ]; };
in
{
  config = {
    activeProfiles = [ "browsing" "development" "home-office" ];

    enabledLanguages = [ "elixir" "erlang" "nix" "python" "rust" ]; # "ocaml"

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages =
      [ nixos.insync keepassWithPlugins pkgs.keybase-gui pkgs.minikube pkgs.lutris pkgs.steam ];

    programs.obs-studio.enable = true;

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
