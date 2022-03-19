{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.tex;
in {
  options.languages.tex = {
    enable = lib.mkEnableOption "LaTeX language support";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep: [ep.auctex];

    programs.emacs.lsp-mode = {
      enable = true;
    };

    programs.emacs.extraInit = ''
      (add-to-list 'exec-path "${pkgs.texlab}/bin")

      (add-hook 'tex-mode-hook
                (lambda ()
                  (company-mode)
                  (flymake-mode)
                  (lsp)))
    '';
  };
}
