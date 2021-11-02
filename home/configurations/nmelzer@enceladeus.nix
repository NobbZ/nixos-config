{ pkgs, ... }:

{
  config = {
    nixpkgs.allowedUnfree = [ "google-chrome" ];

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
      repo = "sftp:nmelzer@tux-nixos.adoring_suess.zerotier:/run/media/nmelzer/data/restic/repo";
    };

    home.packages = [ ];
  };
}
