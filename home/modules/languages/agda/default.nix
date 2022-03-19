{
  config,
  lib,
  ...
}: let
  cfg = config.languages.agda;
in {
  options.languages.agda = {
    enable = lib.mkEnableOption "Agda language support";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      localPackages."init-agda" = {
        tag = "Setup Agda";
        comments = [];
        requires = [];
        packageRequires = ep: with ep.melpaStablePackages; [agda2-mode eri annotation];
        code = ''
          (load-library "agda2-mode")
        '';
      };
    };
  };
}
