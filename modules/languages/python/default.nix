{ config, lib, pkgs, ... }:

let
  cfg = config.languages.python;
  pyls = pkgs.python37Packages.python-language-server;

in {
  options.languages.python = {
    enable = lib.mkEnableOption "Enable support for python language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.lsp-mode = {
      enable = true;
      languages = [ "python" ];
    };

    programs.emacs.extraConfig = ''
            ;; Configure python related stuff
      			(setq lsp-pyls-server-command '("${pyls}/bin/pyls"))
          '';
  };
}
