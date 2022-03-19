{
  config,
  lib,
  ...
}: let
  cfg = config.programs.emacs.packages.beacon;
in {
  options.programs.emacs.packages.beacon = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable `beacon' for emacs.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.localPackages."init-beacon" = {
      tag = "Setup beacon";
      comments = [];
      requires = [];
      code = ''
        ;; enable the beacon minor mode globally.
        (beacon-mode 1)
      '';
    };

    programs.emacs.extraPackages = ep: [ep.beacon];
  };
}
