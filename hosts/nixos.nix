{ ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;

    languages = {
      elixir.enable = true;
      go.enable = true;
      lua.enable = true;
      nix.enable = true;
      python.enable = true;
      terraform.enable = true;
    };

    programs.emacs.splashScreen = false;
  };
}
