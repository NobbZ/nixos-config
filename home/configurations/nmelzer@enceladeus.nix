{ pkgs, lib, statix, ... }:

{
  config = {
    nixpkgs.allowedUnfree = [ "google-chrome" "vscode" ];

    nixpkgs.config.contentAddressedByDefault = false;

    activeProfiles = [ "browsing" "development" ]; # "home-office" ];

    xsession.windowManager.awesome.autostart = [
      "${pkgs.blueman}/bin/blueman-applet"
      "${pkgs.networkmanagerapplet}/bin/nm-applet"
    ];

    enabledLanguages = [ "cpp" "nix" "elixir" "erlang" "python" ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    services.restic = {
      enable = true;
      exclude = (map (e: "%h/${e}") [ ".cache" ".cabal" ".cargo" ".emacs.d/eln-cache" ".emacs.d/.cache" ".gem" ".gradle" ".hex" ".kube" ".local" ".m2" ".minikube" ".minishift" ".mix" ".mozilla" "npm" ".opam" ".rancher" ".vscode-oss" "go/pkg" ]) ++ [ "_build" "deps" "result" "target" ".elixir_ls" "ccls-cache" ".direnv" ];
      oneFileSystem = true;
      repo = "rest:http://172.24.152.168:9999/nobbz";
    };
    systemd.user.timers.restic-backup.Timer.OnCalendar = lib.mkForce "hourly";

    home.packages = [ pkgs.vscode statix.defaultPackage.x86_64-linux ];
  };
}
