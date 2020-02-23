{ ... }:

let cfg = config.programs.advcancedCopy;

in {
  options.programs.advcancedCopy = {
    enable = lib.mkEnableOption "CP and MV with a progressbar";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.advcp ];

    programs.zshell.aliases = {
      cp = "advcp -g";
      mv = "advmv -g";
    };
  };
}
