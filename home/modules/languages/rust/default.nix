_: {
  config,
  lib,
  ...
}: let
  cfg = config.languages.rust;
in {
  options.languages.rust = {
    enable = lib.mkEnableOption "Enable support for Rust language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep: [ep.rust-mode ep.pest-mode];

    programs.emacs.lsp-mode = {
      enable = true;
      languages = ["rust"];
    };

    programs.emacs.extraInit = ''
      (setq lsp-rust-rls-server-command "rls")

      (autoload 'pest-mode "pest-mode")
      (add-to-list #'auto-mode-alist '("\\.pest\\'" .pest-mode))

      (add-hook 'rust-mode-hook
                (lambda ()
                  (subword-mode)
                  (company-mode)
                  (flycheck-mode)
                  (add-hook 'before-save-hook #'lsp-format-buffer nil t)))
    '';
  };
}
