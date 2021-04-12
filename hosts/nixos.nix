{ pkgs, ... }:

{
  config = {
    activeProfiles = [ "browsing" "development" ];

    enabledLanguages =
      [ "elixir" "go" "lua" "nix" "python" "terraform" ];

    # languages.python.useMS = true;

    programs.emacs.splashScreen = false;
    programs.emacs.extraPackages = ep: [ ep.robot-mode ];

    services.gnome-keyring.enable = true;

    home.packages = [
      pkgs.inputs.nixpkgs-stable.legacyPackages.x86_64-linux.mysqlWorkbench
      pkgs.inputs.self.packages.${pkgs.system}.gnucash-de
    ];

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
