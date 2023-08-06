{pkgs, ...}: let
  inherit (pkgs) writeText;
in {
  systemd.user.tmpfiles.rules = let
    xresources = writeText "xresources" ''
      XTerm.vt100.foreground: rgb:d3/d3/d3
      XTerm.vt100.background: rgb:00/00/00
      XTerm.vt100.faceName: FreeMono
      XTerm.vt100.faceSize: 12
    '';
  in [
    "L+ %h/.Xresources - - - - ${xresources}"
  ];
}
