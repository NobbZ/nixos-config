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
  };
}
