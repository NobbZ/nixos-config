{ config, lib, pkgs, ... }:

let
  cfg = config.languages.python;
  pyls = pkgs.python37Packages.python-language-server;

in {
  options.languages.python = {
    enable = lib.mkEnableOption "Enable support for python language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep: [ ep.eglot ep.company ];

    programs.emacs.extraConfig = ''
      ;; Configure python related stuff
      (require 'eglot)
			(add-to-list 'eglot-server-programs
									 '(python-mode . ("${pyls}/bin/pyls")))

			(add-hook 'python-mode-hook
								(lambda ()
									(eglot-ensure)))
    '';
  };
}
