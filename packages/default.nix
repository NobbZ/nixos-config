{
  inputs,
  npins,
  ...
}: {
  perSystem = {
    system,
    pkgs,
    lib,
    inputs',
    ...
  }: let
    upkgs = inputs'.nixpkgs.legacyPackages;

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
          })
          .config
          .system
          .build
          .isoImage;

        advcp = upkgs.callPackage ./advcp {};
        "rofi/unicode" = upkgs.callPackage ./rofi-unicode {};
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
