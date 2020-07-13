{ config, pkgs, ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;
    profiles.home-office.enable = true;

    xsession.windowManager.awesome.terminalEmulator =
      "${pkgs.lxterminal}/bin/lxterminal";

    enabledLanguages = [ "clojure" "nix" "elixir" "erlang" "python" "rust" ];

    programs.emacs.splashScreen = false;
  };
}
