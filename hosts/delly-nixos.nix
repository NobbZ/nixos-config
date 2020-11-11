{ config, pkgs, ... }:

{
  config = {
    activeProfiles = [ "browsing" "development" "home-office" ];

    # xsession.windowManager.awesome.terminalEmulator =
    #   "${pkgs.lxterminal}/bin/lxterminal";

    enabledLanguages = [ "cpp" "clojure" "nix" "elixir" "erlang" "python" ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages = [ ];
  };
}
