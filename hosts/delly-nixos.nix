{ config, ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;
    profiles.home-office.enable = true;

    enabledLanguages = [ "c" "clojure" "nix" "elixir" "erlang" "python" ];

    programs.emacs.splashScreen = false;
  };
}
