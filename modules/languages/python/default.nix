{ config, lib, pkgs, ... }:

let
  cfg = config.languages.python;
  pyls = "${pkgs.python37Packages.python-language-server}/bin/pyls";
  mspyls = "${pkgs.python-language-server}/bin/python-language-server";

  lsBin = if cfg.useMS then mspyls else pyls;
in {
  options.languages.python = {
    enable = lib.mkEnableOption "Enable support for python language";
    useMS = lib.mkEnableOption "Use MS language server rather than palantirs";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.lsp-mode = {
      enable = true;
      languages = [ "python" ];
    };

    programs.emacs.extraConfig = ''
      ;; Configure python related stuff
      (setq lsp-pyls-server-command '("${lsBin}"))
    '';
  };
}
