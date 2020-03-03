{ config, lib, pkgs, ... }:

let
  cfg = config.programs.emacs.whichkey;
  enabled = config.programs.emacs.enable;
in {
  options.programs.emacs.whichkey = {

  };

  config = lib.mkIf enabled {
    programs.emacs.extraPackages = ep: [ ep.which-key ];
    programs.emacs.extraConfig = ''
      (which-key-mode t)
      (setq-default which-key-idle-delay 0.1)
    '';
  };
}
