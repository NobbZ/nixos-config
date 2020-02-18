{ config, lib, pkgs, ... }:

let
  cfg = config.programs.emacs;

  prelude = ''
    ;; -*- mode: emacs-lisp -*-
  '';

in {
  options.programs.emacs = {
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra preferences to add to <filename>init.el</filename>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".emacs.d/init.el" = {
      text = ''
        ${prelude}

        ;; extraConfig
        ${cfg.extraConfig}
      '';
    };
  };
}
