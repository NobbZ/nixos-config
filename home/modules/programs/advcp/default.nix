{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.advancedCopy;
in {
  options.programs.advancedCopy = {
    enable = lib.mkEnableOption "CP and MV with a progressbar";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [self.packages.x86_64-linux.advcp];

    programs.zsh.shellAliases = {
      cp = "advcp -g";
      mv = "advmv -g";
    };
  };
}
