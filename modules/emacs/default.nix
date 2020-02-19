{ config, lib, pkgs, ... }:

let
  emacsEnabled = config.programs.emacs.enable;
  cfg = config.programs.emacs;

  generatePrelude = { name, tagLine ? "", comment ? "", ... }:
    let
      generated = ";; This file is generated via `home-manager' and read only.";
      comment' = (if comment == "" then
        generated
      else
        builtins.concatStringsSep "\n" ([ generated "" ]
          ++ (builtins.map (l: ";; ${l}") (lib.splitString "\n" comment))));
    in ''
      ;;; ${name} --- ${tagLine}

      ;;; Commentary:

      ${comment'}

      ;;; Code:
    '';

  generatePostlude = { name, ... }: ''
    (provide '${name})
    ;;; ${name}.el ends here
  '';

  prelude = generatePrelude {
    name = "init";
    tagLine = "Initialises emacs configuration";
  };

  postlude = generatePostlude { name = "init"; };

in {
  options.programs.emacs = {
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra preferences to add to <filename>init.el</filename>.
      '';
    };
  };

  config = lib.mkIf emacsEnabled {
    home.file.".emacs.d/init.el" = {
      text = ''
        ${prelude}

        ;; extraConfig
        ${cfg.extraConfig}

        ${postlude}
      '';
    };
  };
}
