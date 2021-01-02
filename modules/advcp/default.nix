{ config, lib, pkgs, ... }:
let cfg = config.programs.advancedCopy;

in
{
  options.programs.advancedCopy = {
    enable = lib.mkEnableOption "CP and MV with a progressbar";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.inputs.self.packages.${pkgs.system}.advcp ];

    programs.zshell.aliases = {
      cp = "advcp -g";
      mv = "advmv -g";
    };
  };
}
