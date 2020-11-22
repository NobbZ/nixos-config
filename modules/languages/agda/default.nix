{ config, lib, pkgs, ... }:
let cfg = config.languages.agda;

in
{
  options.languages.agda = {
    enable = lib.mkEnableOption "Agda language support";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      localPackages."init-agda" = {
        tag = "Setup Agda";
        comments = [ ];
        requires = [ ];
        packageRequires = ep: [ ep.agda2-mode ];
        code = ''
          (load-library "agda2-mode")
        '';
      };
    };
  };
}
