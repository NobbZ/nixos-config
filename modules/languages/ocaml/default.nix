{ config, lib, pkgs, ... }:

let cfg = config.languages.ocaml;

in {
  options.languages.ocaml = {
    enable = lib.mkEnableOption "Enable support for ocaml language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.lsp-mode = {
      enable = true;
      languages = [ "caml" ];
    };

    programs.emacs = {
      localPackages."init-ocaml" = {
        tag = "Setup OCaml";
        comments = [ ];
        requires = [ ];
        packageRequires = ep: [ ep.lsp-mode ep.caml ep.company ep.flycheck ];
        code = ''
          (add-to-list 'exec-path "${pkgs.ocaml-lsp}/bin")
          (setq lsp-ocaml-lang-server-command '("ocamllsp"))

          (add-to-list 'auto-mode-alist '("\\.ml[iylp]?$" . caml-mode))
          (autoload 'caml-mode "caml" "Major mode for editing OCaml code." t)

          (add-hook 'caml-mode-hook
                    (lambda ()
                      (require 'caml-font)
                      (subword-mode)
                      (company-mode)
                      (flycheck-mode)))
        '';
      };
    };
  };
}
