{ config, lib, pkgs, ... }:

let cfg = config.languages.ocaml;

in {
  options.languages.ocaml = {
    enable = lib.mkEnableOption "Enable support for ocaml language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      localPackages."init-ocaml" = {
        tag = "Setup OCaml";
        comments = [ ];
        requires = [ ];
        packageRequires = ep: [ ep.lsp-mode ep.caml ep.company ep.flycheck ];
        code = ''
          (add-to-list 'exec-path "${pkgs.ocaml-lsp}/bin")
          (setq lsp-ocaml-lang-server-command '("ocamllsp"))

          (add-hook 'ocaml-mode-hook
                    (lambda ()
                      (subword-mode)
                      (company-mode)
                      (flycheck-mode)))
        '';
      };
    };
  };
}
