{self, ...}: {
  pkgs,
  lib,
  ...
}: let
  self' = self.packages.x86_64-linux;

  baseConfig = pkgs.writeText "launcher-config" ''
    configuration {
      font: "Cascadia Mono PL 20";
      fixed-num-lines: false;
      show-icons: true;
      drun-show-actions: false;
      sidebar-mode: true;
      window-format: "{w}\t| {c}\t| {t}";
      timeout {
          action: "kb-cancel";
          delay:  0;
      }
      filebrowser {
          directories-first: true;
          sorting-method:    "name";
      }
    }
  '';

  launcherConfig = pkgs.writeText "launcher-config" ''
    configuration {
      modes: "drun#run#ssh";
    }
    @import "${baseConfig}"
  '';

  windowSwitcherConfig = pkgs.writeText "window-switcher-config" ''
    configuration {
      modes: "window";
    }
    @import "${baseConfig}"
  '';

  emojiConfig = pkgs.writeText "window-switcher-config" ''
    configuration {
      modes: "emoji#unicode:${self'."rofi/unicode"}/bin/rofiunicode.sh";
    }
    @import "${baseConfig}"
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
