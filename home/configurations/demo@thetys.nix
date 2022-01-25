{ pkgs, nixpkgs-2105, self, ... }:

let
  stable = nixpkgs-2105.legacyPackages.x86_64-linux;
  self' = self.packages.x86_64-linux;
in
{
  config = {
    nixpkgs.allowedUnfree = [ "google-chrome" "vscode" ];

    activeProfiles = [ "browsing" "development" ];

    enabledLanguages =
      [ "elixir" "go" "lua" "nix" "python" "terraform" "nim" "rust" ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;
    programs.emacs.extraPackages = ep: [ ep.robot-mode ];

    services = {
      gnome-keyring.enable = true;

      restic = {
        enable = true;
        exclude = (map
          (e: "%h/${e}")
          [
            ".cache"
            ".cabal"
            ".cargo"
            ".emacs.d/eln-cache"
            ".emacs.d/.cache"
            ".gem"
            ".gradle"
            ".hex"
            ".kube"
            ".local"
            ".m2"
            ".minikube"
            ".minishift"
            ".mix"
            ".mozilla"
            ".npm"
            ".opam"
            ".rancher"
            ".vscode-oss"
            "go/pkg"
            "Videos"
            "Downloads"
            "VirtualBox VMs"
          ]) ++ [
          "_build"
          "deps"
          "result"
          "target"
          ".elixir_ls"
          "ccls-cache"
          ".direnv"
        ];
        repo = "rest:http://172.24.152.168:9999/nobbz";
      };
    };

    home.packages = [
      stable.mysqlWorkbench
      self'.gnucash-de
      pkgs.vscode
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
