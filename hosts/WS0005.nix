{ pkgs, ... }:

{
  config = {
    activeProfiles = [ "browsing" "development" ];

    enabledLanguages = [
      "go"
      "python"
      "nix"
    ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages = [ pkgs.nixUnstable ];

    programs.tmux.secureSocket = false; # disable /run sockets, as those seem to be not available in WSL
  };
}
