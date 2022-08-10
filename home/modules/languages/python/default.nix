_: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.python;
  pyls = "${pkgs.python310Packages.python-lsp-server}/bin/pylsp";
  mspyls = "${pkgs.python-language-server}/bin/python-language-server";

  lsBin =
    if cfg.useMS
    then mspyls
    else pyls;

  lsHook =
    if cfg.useMS
    then "(add-hook 'python-mode-hook (lambda () (require 'lsp-python-ms) (lsp)))"
    else "";
  lsExec =
    if cfg.useMS
    then ''(setq lsp-python-ms-executable "${lsBin}")''
    else ''(setq lsp-pyls-server-command '("${lsBin}"))'';
in {
  options.languages.python = {
    enable = lib.mkEnableOption "Enable support for python language";
    useMS = lib.mkEnableOption "Use MS language server rather than palantirs";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.lsp-mode = {
      enable = true;
      languages =
        if cfg.useMS
        then []
        else ["python"];
    };

    programs.emacs.localPackages."init-python" = {
      tag = "Setup and prepare the python language modes";
      comments = [];
      requires = [];
      packageRequires = ep:
        [
          ep.lsp-pyright
          ep.python-docstring
          (config.programs.emacs.localPackages."init-lsp".packageRequires ep)
        ]
        ++ (
          if cfg.useMS
          then [ep.lsp-python-ms]
          else []
        );
      code = ''
        ${lsHook}

        ${lsExec}

        (add-hook 'python-mode-hook
                  (lambda ()
                    (require 'lsp-pyright)
                    (subword-mode)
                    (company-mode)
                    (flycheck-mode)
                    (python-docstring-mode)
                    (lsp)))
      '';
    };
  };
}
