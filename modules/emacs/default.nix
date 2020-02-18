{ config, lib, pkgs, ... }:

let
  emacsEnabled = config.programs.emacs.enable;
  cfg = config.nobbz.emacs;

  prelude = ''
    ;;; init --- Initialises emacs configuration

    ;;; Commentary:

    ;; This file bootstraps the configuration.
    ;; It is generated via `home-manager' and read only.

    ;;; Code:
  '';

  postlude = ''
    (provide 'init)
    ;;; init.el ends here
  '';

in {
  options.nobbz.emacs = {
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra preferences to add to <filename>init.el</filename>.
      '';
    };
  };

  config = lib.mkIf emacsEnabled {
    home.file.".emacs.d/init.el" = {
      text = ''
        ${prelude}

        ;; extraConfig
        (require 'nix-mode)
        ${cfg.extraConfig}

        ${postlude}
      '';
    };
  };
}
