{ config, lib, pkgs, unstable, ... }:

let
  cfg = config.languages.nim;

  inherit (unstable.legacyPackage.x86_64-linux) nim;
in
{
  options.languages.nim = {
    enable = lib.mkEnableOption "Nim-lang";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      localPackages."init-nim" = {
        tag = "Setup Nim Mode";
        requires = [ "company" "flycheck" ];
        packageRequires = ep: [ ep.nim-mode ep.lsp-mode ep.company ep.flycheck ];
        comments = [ ];
        code = ''
          (add-hook 'nim-mode-hook
                    (lambda ()
                      (subword-mode)
                      (company-mode)
                      (flycheck-mode)
                      (lsp-lens-mode)))
        '';
      };
    };
  };
}
