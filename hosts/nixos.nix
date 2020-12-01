{ pkgs, ... }:

{
  config = {
    activeProfiles = [ "browsing" "development" ];

    enabledLanguages =
      [ "elixir" "go" "lua" "nix" "python" "terraform" ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages = [ pkgs.minikube ];

    systemd.user.services = {
      imwheel = {
        Unit = {
          Description = "IMWheel";
          Wants = [ "display-manager.service" ];
          After = [ "display-manager.service" ];
        };

        Service = {
          Type = "simple";
          Environment = [ "XAUTHORITY=%h/.Xauthority" ];
          ExecStart = "${pkgs.imwheel}/bin/imwheel -d";
          ExecStop = "${pkgs.procps}/bin/pkill imwheel";

          Restart = "on-failure";
          RestartSec = "10";
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
