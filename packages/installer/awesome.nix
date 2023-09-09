{
  lib,
  pkgs,
  npins,
  ...
}: let
  rc_lua = pkgs.runCommandNoCC "awesomerc.lua" {} ''
    substitute ${./awesomerc.lua} $out \
      --subst-var-by FILE_PATH_WALLPAPER ${./nix-glow-black.png} \
      --subst-var-by TERMINAL_ICON_SVG   ${./icons/terminal.svg} \
      --subst-var-by GLOBE_ICON_SVG      ${./icons/globe.svg} \
      --subst-var-by PARTED_ICON_SVG     ${./icons/parted.svg} \
      --subst-var-by NIX_FLAKE_SVG       ${./icons/nix-flake.svg}
  '';

  menu_entries = pkgs.writeText "menu_entries.lua" ''
    return {
      { "NixOS Manual", "nixos-help",                 "${./icons/manual.svg}" },
      { "GParted",      "${lib.getExe pkgs.gparted}", "${./icons/parted.svg}" },
      { "Reboot",       "reboot",                     "${./icons/reboot.svg}" },
      { "Power Off",    "poweroff",                   "${./icons/power-off.svg}" },
    }
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
    "L+ %h/.config/awesome/rc.lua           - - - - ${rc_lua}"
    "L+ %h/.config/awesome/menu_entries.lua - - - - ${menu_entries}"
  ];
}
