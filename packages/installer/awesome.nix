{
  pkgs,
  npins,
  wrapper-manager,
  ...
}: let
  rc_lua = pkgs.runCommandNoCC "awesomerc.lua" {} ''
    substitute ${./awesomerc.lua} $out \
      --subst-var-by FILE_PATH_WALLPAPER ${./nix-glow-black.png}
  '';
  awesome = wrapper-manager.lib.build {
    inherit pkgs;

    modules = [
      {
        wrappers.awesome = {
          basePackage = pkgs.awesome.overrideAttrs (oa: {
            version = npins.awesome.revision;
            src = npins.awesome;

            patches = [];

            postPatch = ''
              patchShebangs tests/examples/_postprocess.lua
            '';
          });

          flags = ["--config" "${rc_lua}"];
        };
      }
    ];
  };
in {
  _file = ./awesome.nix;

  services.xserver.windowManager.awesome = {
    enable = true;
    package = awesome;
  };
}
