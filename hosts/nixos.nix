{ ... }:

{
  config = {
    profiles.browsing.enable = true;
    profiles.development.enable = true;

    enabledLanguages =
      [ "elixir" "go" "lua" "nix" "python" "terraform" "ocaml" ];

    languages.python.useMS = true;

    programs.emacs.splashScreen = false;
  };
}
