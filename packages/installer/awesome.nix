{
  lib,
  pkgs,
  npins,
  ...
}: let
  rc_lua = pkgs.runCommandNoCC "awesomerc.lua" {} ''
    substitute ${./awesomerc.lua} $out \
      --subst-var-by FILE_PATH_WALLPAPER ${./nix-glow-black.png} \
      --subst-var-by TERMINAL_ICON_SVG   ${terminalIcon} \
      --subst-var-by GLOBE_ICON_SVG      ${globeIcon} \
      --subst-var-by PARTED_ICON_SVG     ${partedIcon} \
      --subst-var-by NIX_FLAKE_SVG       ${./nix-flake.svg}
  '';

  fillColor = "#d3d3d3";

  terminalIcon = pkgs.writeText "terminal.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
      <path fill="${fillColor}" d="M20 4H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h16c1.1 0 2-.9 2-2V6a2 2 0 0 0-2-2zm0 14H4V8h16v10zm-2-1h-6v-2h6v2zM7.5 17l-1.41-1.41L8.67 13l-2.59-2.59L7.5 9l4 4l-4 4z"/>
    </svg>
  '';

  globeIcon = pkgs.writeText "globe.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
      <path fill="${fillColor}" d="M16.36 14c.08-.66.14-1.32.14-2c0-.68-.06-1.34-.14-2h3.38c.16.64.26 1.31.26 2s-.1 1.36-.26 2m-5.15 5.56c.6-1.11 1.06-2.31 1.38-3.56h2.95a8.03 8.03 0 0 1-4.33 3.56M14.34 14H9.66c-.1-.66-.16-1.32-.16-2c0-.68.06-1.35.16-2h4.68c.09.65.16 1.32.16 2c0 .68-.07 1.34-.16 2M12 19.96c-.83-1.2-1.5-2.53-1.91-3.96h3.82c-.41 1.43-1.08 2.76-1.91 3.96M8 8H5.08A7.923 7.923 0 0 1 9.4 4.44C8.8 5.55 8.35 6.75 8 8m-2.92 8H8c.35 1.25.8 2.45 1.4 3.56A8.008 8.008 0 0 1 5.08 16m-.82-2C4.1 13.36 4 12.69 4 12s.1-1.36.26-2h3.38c-.08.66-.14 1.32-.14 2c0 .68.06 1.34.14 2M12 4.03c.83 1.2 1.5 2.54 1.91 3.97h-3.82c.41-1.43 1.08-2.77 1.91-3.97M18.92 8h-2.95a15.65 15.65 0 0 0-1.38-3.56c1.84.63 3.37 1.9 4.33 3.56M12 2C6.47 2 2 6.5 2 12a10 10 0 0 0 10 10a10 10 0 0 0 10-10A10 10 0 0 0 12 2Z"/>
    </svg>
  '';

  partedIcon = pkgs.writeText "parted.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
      <path fill="${fillColor}" d="M13 30a11 11 0 0 1 0-22a1 1 0 0 1 1 1v9h9a1 1 0 0 1 1 1a11 11 0 0 1-11 11Zm-1-19.94A9 9 0 1 0 21.94 20H14a2 2 0 0 1-2-2Z"/>
      <path fill="${fillColor}" d="M28 14h-9a2 2 0 0 1-2-2V3a1 1 0 0 1 1-1a11 11 0 0 1 11 11a1 1 0 0 1-1 1Zm-9-2h7.94A9 9 0 0 0 19 4.06Z"/>]] ..
    </svg>
  '';

  powerOffIcon = pkgs.writeText "poweroff.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
      <path fill="#ff0000" d="m16.56 5.44l-1.45 1.45A5.969 5.969 0 0 1 18 12a6 6 0 0 1-6 6a6 6 0 0 1-6-6c0-2.17 1.16-4.06 2.88-5.12L7.44 5.44A7.961 7.961 0 0 0 4 12a8 8 0 0 0 8 8a8 8 0 0 0 8-8c0-2.72-1.36-5.12-3.44-6.56M13 3h-2v10h2"/>
    </svg>
  '';

  rebootIcon = pkgs.writeText "reboot.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
      <path fill="#ff0000" d="M12 4c2.1 0 4.1.8 5.6 2.3c3.1 3.1 3.1 8.2 0 11.3c-1.8 1.9-4.3 2.6-6.7 2.3l.5-2c1.7.2 3.5-.4 4.8-1.7c2.3-2.3 2.3-6.1 0-8.5C15.1 6.6 13.5 6 12 6v4.6l-5-5l5-5V4M6.3 17.6C3.7 15 3.3 11 5.1 7.9l1.5 1.5c-1.1 2.2-.7 5 1.2 6.8c.5.5 1.1.9 1.8 1.2l-.6 2c-1-.4-1.9-1-2.7-1.8Z"/>
    </svg>
  '';

  manualIcon = pkgs.writeText "manual.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
      <path fill="${fillColor}" d="M17.5 14.33c.79 0 1.63.08 2.5.24v1.5c-.62-.16-1.46-.24-2.5-.24c-1.9 0-3.39.33-4.5.99v-1.69c1.17-.53 2.67-.8 4.5-.8M13 12.46c1.29-.53 2.79-.79 4.5-.79c.79 0 1.63.07 2.5.23v1.5c-.62-.16-1.46-.24-2.5-.24c-1.9 0-3.39.34-4.5.99m4.5-3.65c-1.9 0-3.39.32-4.5 1V9.84c1.23-.56 2.73-.84 4.5-.84c.79 0 1.63.08 2.5.23v1.55c-.74-.19-1.59-.28-2.5-.28m3.5 8V7c-1.04-.33-2.21-.5-3.5-.5c-2.05 0-3.88.5-5.5 1.5v11.5c1.62-1 3.45-1.5 5.5-1.5c1.19 0 2.36.16 3.5.5m-3.5-14c2.35 0 4.19.5 5.5 1.5v14.56c0 .12-.05.24-.16.35c-.11.09-.23.17-.34.17c-.11 0-.19-.02-.25-.05c-1.28-.69-2.87-1.03-4.75-1.03c-2.05 0-3.88.5-5.5 1.5c-1.34-1-3.17-1.5-5.5-1.5c-1.66 0-3.25.36-4.75 1.07c-.03.01-.07.01-.12.03c-.04.01-.08.02-.13.02c-.11 0-.23-.04-.34-.12a.475.475 0 0 1-.16-.35V6c1.34-1 3.18-1.5 5.5-1.5c2.33 0 4.16.5 5.5 1.5c1.34-1 3.17-1.5 5.5-1.5Z"/>
    </svg>
  '';

  menu_entries = pkgs.writeText "menu_entries.lua" ''
    return {
      { "NixOS Manual", "nixos-help",                 "${manualIcon}" },
      { "GParted",      "${lib.getExe pkgs.gparted}", "${partedIcon}" },
      { "Reboot",       "reboot",                     "${rebootIcon}" },
      { "Power Off",    "poweroff",                   "${powerOffIcon}" },
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
