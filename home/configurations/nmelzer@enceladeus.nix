{
  self,
  statix,
  ...
}: {
  config,
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

    enabledLanguages = ["cpp" "nix" "elixir" "erlang"];

    programs.emacs.splashScreen = false;

    services.rustic = {
      enable = true;
      package = self.packages.x86_64-linux.rustic-rs;
      globs = let
        mkHome = e: "${config.home.homeDirectory}/${e}";
        mkIgnore = e: "!${e}";

        home = map mkHome [".cache" ".cabal" ".cargo" ".emacs.d/eln-cache" ".emacs.d/.cache" ".gem" ".gradle" ".hex" ".kube" ".local" ".m2" ".minikube" ".minishift" ".mix" ".mozilla" "npm" ".opam" ".rancher" ".vscode-oss" "go/pkg"];
        patterns = ["_build" "deps" "result" "target" ".elixir_ls" "ccls-cache" ".direnv"];
      in
        map mkIgnore (home ++ patterns);
      oneFileSystem = true;
      repo = "rest:https://restic.mimas.internal.nobbz.dev/nobbz";
    };

    home.packages = [pkgs.vscode];
  };
}
