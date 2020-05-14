{ config, ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;
    profiles.home-office.enable = true;

    enabledLanguages = [ "clojure" "nix" "elixir" "erlang" "python" "rust" ];

    programs.emacs.splashScreen = false;
  };
}
