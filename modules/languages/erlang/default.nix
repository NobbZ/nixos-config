{ config, lib, pkgs, ... }:

let
  cfg = config.languages.erlang;
  erlang-ls = pkgs.erlang-ls;
in {
  options.languages.erlang = {
    enable = lib.mkEnableOption "Enable support for erlang language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep:
      with ep; [
        company-lsp
        helm-lsp
        lsp-mode
        lsp-origami
        lsp-ui
        yasnippet
        erlang
      ];

    programs.emacs.extraConfig = ''
      ;; Configure erlang related stuff

      (yas-global-mode t)

      (setq lsp-erlang-server-path "${erlang-ls}/bin/erlang_ls")
      (setq lsp-log-io t)
      (setq lsp-ui-sideline-enable t)
      (setq lsp-ui-doc-enable t)
      (setq lsp-ui-doc-position 'bottom)

      (push 'company-lsp company-backends)

      (eval-after-load 'erlang
        '(define-key erlang-mode-map (kbd "C-M-i") #'company-lsp))

      (add-hook 'erlang-mode-hook
                (lambda ()
                  (linum-mode)
                  ('column-number-mode)
                  (lsp)
                  (add-hook 'before-save-hook 'lsp-format-buffer nil t)
                  (subword-mode)
                  (company-mode)
                  (flymake-mode)))

      (add-hook 'origami-mode-hook 'lsp-origami-mode)
      (add-hook 'erlang-mode-hook 'origami-mode)
    '';
  };
}
