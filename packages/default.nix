{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    lib,
    inputs',
    ...
  }: let
    upkgs = inputs'.nixpkgs.legacyPackages;

    epkgs = upkgs.extend inputs.emacs.overlay;
    chromePkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.google-chrome.enableWideVine = true;
    };
  in {
    packages = lib.mkMerge [
      {
        advcp = upkgs.callPackage ./advcp {};
        "dracula/konsole" = upkgs.callPackage ./dracula/konsole {};
        emacs = epkgs.emacs-unstable;
        "rofi/unicode" = upkgs.callPackage ./rofi-unicode {};
        "zx" = upkgs.nodePackages.zx;
      }
      (lib.mkIf pkgs.stdenv.isLinux {
        inherit (inputs'.switcher.packages) switcher;
      })
      (lib.mkIf (system == "x86_64-linux") {
        inherit (chromePkgs) google-chrome;
      })
    ];
  };
}
