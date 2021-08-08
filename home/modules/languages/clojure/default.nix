{ config, lib, pkgs, ... }:
let cfg = config.languages.clojure;

in
{
  options.languages.clojure = {
    enable = lib.mkEnableOption "Enable support for the clojure language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      extraPackages = ep: [ ep.clojure-mode ];

      lsp-mode = {
        enable = true;
        languages = [ "clojure" ];
      };

      extraInit = ''
        (setenv "PATH"
                (concat "${pkgs.leiningen}/bin:" (getenv "PATH")))
        (setq lsp-clojure-server-command '("${pkgs.bash}/bin/bash" "-c" "${pkgs.clojure-lsp}/bin/clojure-lsp"))
      '';
    };
  };
}
