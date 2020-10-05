{ config, pkgs, ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;
    profiles.home-office.enable = true;

    # xsession.windowManager.awesome.terminalEmulator =
    #   "${pkgs.lxterminal}/bin/lxterminal";

    enabledLanguages = [ "clojure" "nix" "elixir" "erlang" "python" ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages = [ ];
  };
}
