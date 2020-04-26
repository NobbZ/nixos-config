{ ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;

    enabledLanguages = [ "elixir" "go" "lua" "nix" "python" "terraform" ];

    programs.emacs.splashScreen = false;
  };
}
