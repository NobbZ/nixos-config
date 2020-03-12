{ config, lib, pkgs, ... }:

let
  emacsEnabled = config.programs.emacs.enable;
  cfg = config.programs.emacs;

  bool2Lisp = b: if b then "t" else "nil";

in {
  imports = [ ./polymode ./whichkey ];

  options.programs.emacs = {
    splashScreen = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enable the startup screen.
      '';
    };

    # TODO: rewrite into a "named" submodule
    localPackages = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          tag = lib.mkOption { type = lib.types.str; };
          comments = lib.mkOption { type = lib.types.listOf lib.types.str; };
          requires = lib.mkOption { type = lib.types.listOf lib.types.str; };
          code = lib.mkOption { type = lib.types.str; };
        };
      });
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra preferences to add to <filename>init.el</filename>.
      '';
    };

    packages.beacon.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable `beacon' for emacs.
      '';
    };

    module = lib.mkOption {
      description = "Attribute set of modules to link into emacs configuration";
      default = { };
    };
  };

  config = lib.mkIf emacsEnabled {
    programs.emacs.extraConfig = ''
      ;; set splash screen
      (setq inhibit-startup-screen ${bool2Lisp (!cfg.splashScreen)})

      ;; set up telephone line
      (setq-default
       telephone-line-lhs '((accent . (telephone-line-vc-segment
                                       telephone-line-erc-modified-channels-segment
                                       telephone-line-process-segment))
                           (nil     . (telephone-line-minor-mode-segment
                                       telephone-line-buffer-segment)))
       telephone-line-rhs '((nil    . (telephone-line-misc-info-segment))
                            (accent . (telephone-line-major-mode-segment))
                            (accent . (telephone-line-airline-position-segment))))

      (telephone-line-mode t)

      ;; company
      (setq tab-always-indent 'complete)
      (add-to-list 'completion-styles 'initials t)

      ;; (eval-when-compile (require 'company))

      (add-hook 'after-init-hook 'global-company-mode)
      (with-eval-after-load 'company
        ;; (diminish 'company-mode "CMP")
        (define-key company-mode-map   (kbd "M-+") '("complete"       . 'company-complete))
        (define-key company-active-map (kbd "M-+") '("change backend" . 'company-other-backend))
        (define-key company-active-map (kbd "C-n") '("next"           . 'company-select-next))
        (define-key company-active-map (kbd "C-p") '("previous"       . 'company-select-previous))
        (setq-default company-dabbrev-other-buffers 'all
                      company-tooltip-align-annotations t))
    '';

    programs.emacs.extraPackages = ep: [
      ep.beacon
      ep.telephone-line
      ep.company
    ];

    home.file.".emacs.d/init.el" = {
      text = pkgs.nobbzLib.emacs.generatePackage "init"
        "Initialises emacs configuration" [ ] [ ] cfg.extraConfig;
    };
  };
}
