{inputs, ...}: {
  _file = ./default.nix;

  perSystem = {
    system,
    pkgs,
    lib,
    inputs',
    ...
  }: let
    upkgs = inputs'.nixpkgs-unstable.legacyPackages;

    epkgs = upkgs.extend inputs.emacs.overlay;
    chromePkgs = import inputs.master {
      inherit system;
      config.allowUnfree = true;
      config.google-chrome.enableWideVine = true;
    };

    nilBase =
      if upkgs.stdenv.isLinux
      then inputs'.nil.packages.nil
      else upkgs.nil;

    rnil-lsp = upkgs.writeShellScriptBin "rnix-lsp" ''
      exec ${nilBase}/bin/nil "$@"
    '';

    nil = upkgs.symlinkJoin {
      name = "nil";
      paths = [nilBase rnil-lsp];
    };
  in {
    packages = lib.mkMerge [
      {
        inherit nil;

        advcp = upkgs.callPackage ./advcp {};
        "dracula/konsole" = upkgs.callPackage ./dracula/konsole {};
        emacs = epkgs.emacs-unstable;
        "rofi/unicode" = upkgs.callPackage ./rofi-unicode {};
        "zx" = upkgs.nodePackages.zx;

        alejandra = inputs'.alejandra.packages.default;
      }
      (lib.mkIf pkgs.stdenv.isLinux {
        inherit (inputs'.switcher.packages) switcher;
        gnucash-de = upkgs.callPackage ./gnucash-de {};
      })
      (lib.mkIf (system == "x86_64-linux") {
        inherit (chromePkgs) google-chrome;
      })
    ];
  };
}
