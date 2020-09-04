{ pkgs, ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;

    enabledLanguages =
      [ "elixir" "go" "lua" "nix" "python" "terraform" ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;

    home.packages = [ pkgs.minikube ];
  };
}
