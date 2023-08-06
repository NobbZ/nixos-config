{
  pkgs,
  npins,
  ...
}: let
  awesome = pkgs.awesome.overrideAttrs (oa: {
    version = npins.awesome.revision;
    src = npins.awesome;

    patches = [];

    postPatch = ''
      patchShebangs tests/examples/_postprocess.lua
    '';
  });
in {
  _file = ./awesome.nix;

  services.xserver.windowManager.awesome = {
    enable = true;
    package = awesome;
  };
}
