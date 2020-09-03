{ config, lib, pkgs, ... }:
let cfg = config.languages.rust;

in
{
  options.languages.rust = {
    enable = lib.mkEnableOption "Enable support for Rust language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep: [ ep.rust-mode ];

    programs.emacs.lsp-mode = {
      enable = true;
      languages = [ "rust" ];
    };

    programs.emacs.extraConfig = ''
      (add-to-list 'exec-path "${pkgs.rls}/bin")
      (setq lsp-rust-rls-server-command "rls")

      (add-hook 'rust-mode-hook
                (lambda ()
                  (subword-mode)
                  (company-mode)
                  (flycheck-mode)
                  (add-hook 'before-save-hook #'lsp-format-buffer nil t)))
    '';
  };
}
