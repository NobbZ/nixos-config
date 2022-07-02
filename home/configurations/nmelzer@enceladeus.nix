{statix, ...}: {
  pkgs,
  lib,
  ...
}: {
  config = {
    nixpkgs.allowedUnfree = ["google-chrome" "vscode"];

    nixpkgs.config.contentAddressedByDefault = false;

    activeProfiles = ["browsing" "development"];

    xsession.windowManager.awesome.autostart = [
      "${pkgs.blueman}/bin/blueman-applet"
      "${pkgs.networkmanagerapplet}/bin/nm-applet"
    ];

    enabledLanguages = ["cpp" "nix" "elixir" "erlang" "python"];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    services.restic = {
      enable = true;
      exclude = (map (e: "%h/${e}") [".cache" ".cabal" ".cargo" ".emacs.d/eln-cache" ".emacs.d/.cache" ".gem" ".gradle" ".hex" ".kube" ".local" ".m2" ".minikube" ".minishift" ".mix" ".mozilla" "npm" ".opam" ".rancher" ".vscode-oss" "go/pkg"]) ++ ["_build" "deps" "result" "target" ".elixir_ls" "ccls-cache" ".direnv"];
      oneFileSystem = true;
      repo = "rest:https://restic.mimas.internal.nobbz.dev/nobbz";
    };
    systemd.user.timers.restic-backup.Timer.OnCalendar = lib.mkForce "hourly";

    home.packages = [pkgs.vscode];
  };
}
