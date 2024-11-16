{
  config,
  lib,
  ...
}: let
  inherit (config.programs) emacs;
in {
  config = lib.mkIf emacs.enable {
    programs.emacs.extraPackages = ep: [ep.polymode];

    programs.emacs.localPackages."init-polymode" = {
      tag = "Setup and initialise polymode";
      comments = [];
      requires = [];
      code = ''
        ;; polymode
        (add-to-list 'auto-mode-alist '("\\.nix$" . poly-nix-mode))

        (define-hostmode poly-nix-hostmode :mode 'nix-mode)

        (define-innermode poly-elisp-expr-nix-innermode
          :mode 'emacs-lisp-mode
          :head-matcher (cons "'''\n\\( *;;.*\n\\)" 1)
          :tail-matcher " *''';$"
          :head-mode 'body
          :tail-mode 'host)

        (define-polymode poly-nix-mode
          :hostmode 'poly-nix-hostmode
          :innermodes '(poly-elisp-expr-nix-innermode))
      '';
    };
  };
}
