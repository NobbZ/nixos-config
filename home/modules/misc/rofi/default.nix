{self, ...}: {
  pkgs,
  lib,
  npins,
  ...
}: let
  self' = self.packages.x86_64-linux;

  common_rasi = pkgs.runCommandNoCC "common.rasi" {preferLocalBuild = true;} ''
    substitute ${./common.rasi} $out \
      --subst-var-by TERMINAL ${lib.getExe pkgs.wezterm}
  '';

  catppuccin = pkgs.runCommandNoCC "catppuccin.rasi" {preferLocalBuild = true;} ''
    substitute ${npins.catppuccin-rofi}/catppuccin-default.rasi $out \
      --replace-fail '"catppuccin-mocha"' '"${npins.catppuccin-rofi}/themes/catppuccin-mocha.rasi"'
  '';

  launcherConfig = pkgs.writeText "launcher-config" ''
    configuration {
      modes: "drun#run#ssh";
    }
    @theme "${catppuccin}"
    @import "${common_rasi}"
  '';

  windowSwitcherConfig = pkgs.writeText "window-switcher-config" ''
    configuration {
      modes: "window";
    }
    @theme "${catppuccin}"
    @import "${common_rasi}"
  '';

  emojiConfig = pkgs.writeText "window-switcher-config" ''
    configuration {
      modes: "emoji#unicode:${self'."rofi/unicode"}/bin/rofiunicode.sh";
    }
    @theme "${catppuccin}"
    @import "${common_rasi}"
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
