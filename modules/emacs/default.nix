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

  bool2Lisp = b: if b then "t" else "nil";

in {
  imports = [ ./whichkey ];

  options.programs.emacs = {
    splashScreen = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enable the startup screen.
      '';
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra preferences to add to <filename>init.el</filename>.
      '';
    };

    packages.beacon.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable `beacon' for emacs.
      '';
    };

    module = lib.mkOption {
      description = "Attribute set of modules to link into emacs configuration";
      default = { };
    };
  };

  config = lib.mkIf emacsEnabled {
    programs.emacs.extraConfig = ''
      (setq inhibit-startup-screen ${bool2Lisp (!cfg.splashScreen)})

      (setq-default
       telephone-line-lhs '((accent . (telephone-line-vc-segment
                                       telephone-line-erc-modified-channels-segment
                                       telephone-line-process-segment))
                           (nil     . (telephone-line-minor-mode-segment
                                       telephone-line-buffer-segment)))
       telephone-line-rhs '((nil    . (telephone-line-misc-info-segment))
                            (accent . (telephone-line-major-mode-segment))
                            (accent . (telephone-line-airline-position-segment))))

      (telephone-line-mode t)
    '';

    programs.emacs.extraPackages = ep: [ ep.beacon ep.telephone-line ];

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
