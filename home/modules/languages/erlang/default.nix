{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.erlang;

  inherit (self.packages.x86_64-linux) erlang-ls;
in {
  options.languages.erlang = {
    enable = lib.mkEnableOption "Enable support for erlang language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep: [
      (ep.erlang.overrideAttrs (oa: {
        buildInputs = oa.buildInputs ++ [pkgs.perl pkgs.ncurses];
      }))
    ];

    programs.emacs.lsp-mode = {
      enable = true;
      languages = ["erlang"];
    };

    programs.emacs.extraInit = ''
      ;; Configure erlang related stuff
      (setq lsp-erlang-server-path "${erlang-ls}/bin/erlang_ls")

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
                  (flycheck-mode)))

      (add-hook 'origami-mode-hook 'lsp-origami-mode)
      (add-hook 'erlang-mode-hook  'origami-mode)
    '';
  };
}
