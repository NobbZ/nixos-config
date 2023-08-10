{
  pkgs,
  npins,
  ...
}: let
  rc_lua = pkgs.runCommandNoCC "awesomerc.lua" {} ''
    substitute ${./awesomerc.lua} $out \
      --subst-var-by FILE_PATH_WALLPAPER ${./nix-glow-black.png} \
      --subst-var-by NIX_FLAKE_SVG       ${./nix-flake.svg}
  '';
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

  systemd.user.tmpfiles.rules = [
    "L+ %h/.config/awesome/rc.lua - - - - ${rc_lua}"
  ];
}
