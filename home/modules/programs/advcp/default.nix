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
    home.packages = [self.packages.${pkgs.stdenv.hostPlatform.system}.advcp];

    programs.zsh.shellAliases = {
      cp = "advcp -g";
      mv = "advmv -g";
    };
  };
}
