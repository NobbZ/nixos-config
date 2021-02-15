{ ... }:

{
  config = {
    activeProfiles = [ "browsing" "development" "home-office" ];

    # xsession.windowManager.awesome.terminalEmulator =
    #   "${pkgs.lxterminal}/bin/lxterminal";

    xsession.windowManager.awesome.autostart = [
      "${pkgs.blueman}/bin/blueman-applet"
      "${pkgs.networkmanagerapplet}/bin/nm-applet"
    ];

    enabledLanguages = [ "cpp" "clojure" "nix" "elixir" "erlang" "python" ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages = [ ];
  };
}
