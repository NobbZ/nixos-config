{self, ...}: {
  pkgs,
  lib,
  ...
}: let
  self' = self.packages.x86_64-linux;

  launcherConfig = pkgs.writeText "launcher-config" ''
    configuration {
      modes: "drun#run#ssh";
    }
    @import "${./common.rasi}"
  '';

  windowSwitcherConfig = pkgs.writeText "window-switcher-config" ''
    configuration {
      modes: "window";
    }
    @import "${./common.rasi}"
  '';

  emojiConfig = pkgs.writeText "window-switcher-config" ''
    configuration {
      modes: "emoji#unicode:${self'."rofi/unicode"}/bin/rofiunicode.sh";
    }
    @import "${./common.rasi}"
  '';

  wrapper = rofi: config:
    pkgs.callPackage ({
      rofi,
      runCommandNoCC,
      makeWrapper,
    }:
      runCommandNoCC "rofi" {
        nativeBuildInputs = [makeWrapper];
        inherit (rofi) meta;
      } ''
        mkdir -p $out/bin
        makeWrapper ${lib.getExe rofi} $out/bin/rofi \
          --add-flags "-config ${config}"
      '') {inherit rofi;};

  launcherPkg = pkgs.rofi;
  windowSwitcherPkg = pkgs.rofi;
  emojiPkg = pkgs.rofi.override {plugins = [pkgs.rofi-emoji];};

  launcher = wrapper launcherPkg launcherConfig;
  windowSwitcher = wrapper windowSwitcherPkg windowSwitcherConfig;
  emoji = wrapper emojiPkg emojiConfig;
in {
  xsession.windowManager.awesome.launcher = "${lib.getExe launcher} -show drun";
  xsession.windowManager.awesome.windowSwitcher = "${lib.getExe windowSwitcher} -show window";
  xsession.windowManager.awesome.emojiPicker = "${lib.getExe emoji} -show emoji";
}
