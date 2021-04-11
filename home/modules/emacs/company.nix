{ config, lib, ... }:

with lib;
let emacs = config.programs.emacs;
in
{
  config = lib.mkIf emacs.enable {
    programs.emacs.extraPackages = ep: [ ep.company ];

    programs.emacs.localPackages."init-company" = {
      tag = "Setup and initialise company";
      comments = [ ];
      requires = [ ];
      code = ''
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
                      company-tooltip-align-annotations t
                      company-minimum-prefix-length 1
                      company-idle-delay 0.05))
      '';
    };
  };
}
