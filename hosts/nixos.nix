{ ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;

    languages = {
      nix.enable = true;
      elixir.enable = true;
      python.enable = true;
    };

    programs.emacs.splashScreen = false;
  };
}
