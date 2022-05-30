{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.talon;
in {
  options.services.talon.enable = lib.mkEnableOption "talon";

  config.services.udev.packages = lib.mkIf cfg.enable [self.packages.${pkgs.system}.talon];
}
