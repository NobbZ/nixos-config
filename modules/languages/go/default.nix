{ config, lib, pkgs, ... }:

let cfg = config.languages.go;

in {
  options.languages.go = {
    enable = lib.mkEnableOption "Enable support for the go language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep: [ ep.go-mode ];

    programs.emacs.lsp-mode = {
      enable = true;
      languages = [ "go" ];
    };

    home.packages = [ pkgs.go ];

    programs.emacs.extraConfig = ''
      (add-to-list 'exec-path "${pkgs.gopls}/bin")

      (add-hook 'go-mode-hook
                (lambda ()
                  (subword-mode)
                  (company-mode)
                  (flymake-mode)
                  (add-hook 'before-save-hook #'lsp-format-buffer nil t)))
    '';
  };
}
