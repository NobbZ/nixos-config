{
  pkgs,
  self',
  ...
}: let
  rc_lua = pkgs.runCommand "awesomerc.lua" {} ''
    substitute ${./awesomerc.lua} $out \
      --subst-var-by FILE_PATH_WALLPAPER ${./nix-glow-black.png} \
      --subst-var-by NIX_FLAKE_SVG       ${./nix-flake.svg}
  '';
in {
  _file = ./awesome.nix;

  services.xserver.windowManager.awesome = {
    enable = true;
    package = self'.packages.awesome;
  };

  systemd.user.tmpfiles.rules = [
    "L+ %h/.config/awesome/rc.lua - - - - ${rc_lua}"
  ];
}
