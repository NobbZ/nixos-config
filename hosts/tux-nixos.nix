{ pkgs, config, ... }:

let
  keepassWithPlugins =
    pkgs.keepass.override { plugins = [ pkgs.keepass-keepasshttp ]; };
in {
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;
    profiles.home-office.enable = true;

    languages = {
      elixir.enable = true;
      erlang.enable = true;
      nix.enable = true;
      python.enable = true;
    };

    programs.emacs.splashScreen = false;

    home.packages = [ pkgs.insync keepassWithPlugins pkgs.keybase-gui ];

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
