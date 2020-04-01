{ config, lib, pkgs, ... }:

let
  cfg = config.languages.erlang;
  erlang-ls = pkgs.erlang-ls;
in {
  options.languages.erlang = {
    enable = lib.mkEnableOption "Enable support for erlang language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep: [ ep.eglot ep.erlang ep.company ];

    programs.emacs.extraConfig = ''
            ;; Configure erlang related stuff
            (require 'eglot)
      			(add-to-list 'eglot-server-programs
      									 '(erlang-mode . ("${erlang-ls}/bin/erlang-ls")))

      			(add-hook 'erlang-mode-hook
      								(lambda ()
      									(add-hook 'before-save-hook #'eglot-format-buffer nil t)
      									(subword-mode)
      									(eglot-ensure)
      									(company-mode)
      									(flymake-mode)))
          '';
  };
}
