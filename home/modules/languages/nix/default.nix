_: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.nix;

  # rnixLsp = rnix-lsp.defaultPackage.x86_64-linux;
  inherit (pkgs) nil;
in {
  options.languages.nix = {
    enable = lib.mkEnableOption "nix language for emacs";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep: [ep.lsp-mode ep.nix-mode ep.flycheck];

    programs.emacs.extraInit = ''
      (require 'lsp-mode)

      ;; make lsp-mode aware of nix
      (add-to-list 'lsp-language-id-configuration '(nix-mode . "nix"))
      (lsp-register-client
       (make-lsp-client :new-connection (lsp-stdio-connection '("${nil}/bin/nil"))
                        :major-modes '(nix-mode)
                        :server-id 'nix))

      (add-hook 'nix-mode-hook
                (lambda ()
                  (lsp)
                  (subword-mode)
                  (company-mode)
                  (flycheck-mode)))
    '';
  };
}
