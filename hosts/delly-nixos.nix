{ config, ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;
    profiles.home-office.enable = true;

    languages = {
      nix.enable = true;
      elixir.enable = true;
      erlang.enable = true;
      python.enable = true;
    };

    programs.emacs.splashScreen = false;
  };
}
