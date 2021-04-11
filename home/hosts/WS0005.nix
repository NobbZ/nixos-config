{ pkgs, ... }:

{
  config = {
    activeProfiles = [ "browsing" "development" ];

    enabledLanguages = [
      "erlang"
      "go"
      "nix"
      "python"
    ];

    programs.zsh.initExtraBeforeCompInit = ''
      . ~/.nix-profile/etc/profile.d/nix.sh
    '';

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages = [ pkgs.nixUnstable ];

    programs.tmux.secureSocket = false; # disable /run sockets, as those seem to be not available in WSL
  };
}
