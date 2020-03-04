{ config, lib, pkgs, ... }:

with lib;

let emacs = config.programs.emacs;
in {
  config = lib.mkIf emacs.enable {
    programs.emacs.extraPackages = ep: [ ep.polymode ];
    programs.emacs.extraConfig = ''
      ;; polymode
      (add-to-list 'auto-mode-alist '("\\.nix$" . poly-nix-mode))

      (define-hostmode poly-nix-hostmode :mode 'nix-mode)

      (define-innermode poly-elisp-expr-nix-innermode
        :mode 'emacs-lisp-mode
        :head-matcher "'''\n *;;.*\n"
        :tail-matcher " *''';$"
        :head-mode 'host
        :tail-mode 'host)

      (define-polymode poly-nix-mode
        :hostmode 'poly-nix-hostmode
        :innermodes '(poly-elisp-expr-nix-innermode))
    '';
  };
}
