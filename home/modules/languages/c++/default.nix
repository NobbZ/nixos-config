_: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.cpp;

  inherit (pkgs) ccls;
in {
  options.languages.cpp = {
    enable = lib.mkEnableOption "Enable support for C++ language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      localPackages."init-cpp" = {
        tag = "Setup C++";
        requires = ["ccls"];
        packageRequires = ep: [ep.ccls];
        comments = [];
        code = ''
          (setq ccls-executable "${ccls}/bin/ccls")
        '';
      };
    };

    programs.git.ignores = [
      ".ccls-cache/"
    ];
  };
}
