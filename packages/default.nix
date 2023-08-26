{
  inputs,
  npins,
  ...
}: {
  _file = ./default.nix;

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

    awesome = pkgs.awesome.overrideAttrs (oa: {
      version = npins.awesome.revision;
      src = npins.awesome;

      patches = [];

      postPatch = ''
        patchShebangs tests/examples/_postprocess.lua
      '';
    });
  in {
    packages = lib.mkMerge [
      {
        installer-iso =
          (upkgs.callPackage ./installer {
            inherit (inputs.nixpkgs.lib) nixosSystem;
            inherit npins;
            inherit (inputs) nvim;
          })
          .config
          .system
          .build
          .isoImage;

        advcp = upkgs.callPackage ./advcp {};
        "dracula/konsole" = upkgs.callPackage ./dracula/konsole {};
        emacs = epkgs.emacs-unstable;
        "rofi/unicode" = upkgs.callPackage ./rofi-unicode {};
        "zx" = upkgs.nodePackages.zx;
      }
      (lib.mkIf pkgs.stdenv.isLinux {
        inherit (inputs'.switcher.packages) switcher;
        inherit awesome;
      })
      (lib.mkIf (system == "x86_64-linux") {
        inherit (chromePkgs) google-chrome;
      })
    ];
  };
}
