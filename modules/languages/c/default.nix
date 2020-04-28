{ config, lib, pkgs, ... }:

let enabled = config.languages.c.enable || config.languages.cpp.enable;

in {
  options.languages.c = {
    enable = lib.mkEnableOption "Enable support for C language";
  };

  options.languages.cpp = {
    enable = lib.mkEnableOption "Enable support for C++ language";
  };

  config = lib.mkIf enabled {
    programs.emacs.extraPackages = ep: [ ep.cmake-mode ];

    programs.emacs.lsp-mode = {
      enable = true;
      languages = [ "c" "c++" ];
    };

    programs.emacs.extraConfig = ''
      (setq lsp-clients-clangd-executable "${pkgs.clang-tools}/bin/clangd")
    '';
  };
}
